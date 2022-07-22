// Custom Ramp up and down on open flow in this code.

//#include <lorawan.h>
#include <RHReliableDatagram.h>
#include <RH_RF95.h>
#include <SPI.h>
#include "wiring_private.h" // pinPeripheral() function
//#include <time.h>
SPIClass mySPI (&sercom0, A3, A4, 9, SPI_PAD_3_SCK_1, SERCOM_RX_PAD_0);

const byte WREN = 6;
const byte WRDI = 4;
const byte RDSR = 5;
const byte WRSR = 1;
const byte READ = 3;
const byte WRITE = 2;

byte flash_output_data [256] = "\0";
byte buffer [256] = "\0";

const uint16_t CS = A5;
const uint16_t WP = A0;
const uint16_t HD = 1;

#define CLIENT_ADDRESS 1
#define SERVER_ADDRESS 49 //49  = 1, 50 = 2
#define MAX_RESEND_TIME 1
uint16_t resend_time;

RH_RF95 driver(8, 3);

//String inputString = "";         // a String to hold incoming data
//bool stringComplete = false;
//char mes[8];

RHReliableDatagram manager(driver, SERVER_ADDRESS);

//ABP Credentials
//const char *devAddr = "26021627";
const char *devAddr = "92504991";
const char *nwkSKey = "EDF10594AA9B779BF9D75867CED4D96E";
const char *appSKey = "F7BB3FBF52315CA562047BFFBC59D56E";

const unsigned long interval = 1000; // 10 s interval to send message
unsigned long previousMillis = 0;    // will store last time message sent
uint16_t counter = 0;            // message counter

char myStr[50];
char outStr[255];
byte recvStatus = 0;

//const sRFM_pins RFM_pins = {
//    .CS = 8,
//    .RST = 4,
//    .DIO0 = 3,
//    .DIO1 = 6,
//    .DIO2 = -1,
//    .DIO5 = -1,
//};

//Frequency & Timer
#define MAX_COMMAND_LENGTH 40
#define CPU_HZ 48000000
#define TIMER_PRESCALER_DIV 64

//Head & Valve Speed & Position
#define DEFAULT_HEAD_SPEED 50 //100
#define DEFAULT_HEAD_sV 900
#define HEAD_SLACK 3
#define HEAD_RAMP 1
#define HEAD_PRECISION 1
#define HEAD_POS_COUNT 3
#define HEAD_V_HOME 50//100

#define DEFAULT_VALVE_SPEED 50 // Final speed for valve motor
#define DEFAULT_VALVE_sV 500 // Initial speed for valve motor
#define VALVE_SLACK 3
#define VALVE_RAMP 1
#define VALVE_PRECISION 1
#define VALVE_POS_COUNT 3
#define VALVE_V_HOME 50 // Home speed for valve motor
#define VALVE_V_HOME_RESET 900 // reset home speed after 2220 steps with slower speed
//Pin index set
//TODO: Update according to the adafruit pin and PCB
#define HEAD_SLEEP 6
#define HEAD_DIR 12
#define HEAD_STEP 10
#define HEAD_HOME 7

#define VALVE_SLEEP 11
#define VALVE_DIR 5
#define VALVE_STEP A1
#define VALVE_HOME 2

//Constant set
#define CLOCKWISE 0
#define COUNTERCLOCKWISE 1
#define OPEN_DIR COUNTERCLOCKWISE
#define CLOSE_DIR CLOCKWISE
#define IDLING 0
#define RUNNING 1
#define STOP1 2
#define STOP2 3
#define CYCLING 4
#define CYCLINGSTART 5
#define CYCLINGEND 6
#define STEP_PER_ANGLE 1465
#define STEP_PER_DEGREE 215
#define FLOW_QUEUE_LENGTH 40
#define MAX_HOME_COUNTER 100
#define acl_count_max 10   // Ramping variable set to 0.1 (lower the value the slower, more smoother the ramp), conversion is ( 1 / 0.1 = 10 )
#define acl_off_count_max 4
//Motor Orders
#define HEAD_CLOCKWISE digitalWrite(HEAD_DIR, HIGH)
#define HEAD_COUNTERCLOCKWISE digitalWrite(HEAD_DIR, LOW)
#define HEAD_HOME_FLAG (digitalRead(HEAD_HOME) == HIGH)
#define head_half_cycle head_TC->CC[0].reg
#define head_sleep() digitalWrite(HEAD_SLEEP, LOW)
#define head_awake() digitalWrite(HEAD_SLEEP, HIGH)

#define VALVE_CLOCKWISE digitalWrite(VALVE_DIR, HIGH)
#define VALVE_COUNTERCLOCKWISE digitalWrite(VALVE_DIR, LOW)
#define VALVE_HOME_FLAG (digitalRead(VALVE_HOME) == HIGH)
#define valve_half_cycle valve_TC->CC[0].reg
#define valve_sleep() digitalWrite(VALVE_SLEEP, LOW)
#define valve_awake() digitalWrite(VALVE_SLEEP, HIGH)

char message[400];
char *pointer = message;
char mes;

const char CR = '\r';
int rt, of;
int head_counter;
int valve_counter;
int pre_level = 1;
boolean cycle_reverse = false;
int cycle_start;
int cycle_end;
int ii = 1;

int head_pos;
int head_target;
int head_total_step;
int head_ramp_dowm;
uint16_t head_v;
int head_degree;
uint16_t head_state;
uint16_t head_dir;
uint16_t last_update_head_pos;
int head_step_count;
int head_cycle_target;
uint16_t head_offset;
TcCount16 *head_TC = (TcCount16 *)TC3;

uint16_t valve_pos;
uint16_t valve_target;
uint16_t valve_total_step;
uint16_t valve_ramp_up_deg;
uint16_t valve_ramp_up;
uint16_t valve_ramp_down_deg;
uint16_t valve_ramp_down;
uint16_t valve_v;
uint16_t valve_degree;
uint16_t valve_dir;
uint16_t valve_state;
uint16_t flow_que[370];
uint16_t valve_step_count;
uint16_t valve_offset;
//clock_t valve_timer_start, valve_timer_end;
// unsigned long valve_timer_start;
// unsigned long valve_timer_end;
// unsigned long valve_timer_diff
int valve_home_step_count=0;
int valve_home_degree=0;
int valve_reset_flag=0; //1: value home reset const slow speed
int valve_home_deg_shut=0;

TcCount16 *valve_TC = (TcCount16 *)TC4;
int acl_count = 0;
int acl_off_count = 0;
unsigned long lastsystime;
unsigned long tailsystime;
uint16_t clock_counter = 0;

uint8_t receive[] = "Recvive";
// Dont put this on the stack:
uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
uint8_t recv_buf[RH_RF95_MAX_MESSAGE_LEN];

void setup()
{
  Serial.begin(115200);
//  while (!Serial) {}
  ioinit();
  flashinit();
  calendarinit();
  //  pinMode(4, OUTPUT);
  //  digitalWrite(4, HIGH);

  Serial.println("Ready to start");
  if (!manager.init())
    Serial.println("init failed\n");
  driver.setFrequency(914.2);
  driver.setTxPower(23,false); //Max transmission power
  
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED off by making the voltage LOW
  delay(1000);                     // wait for a second
  digitalWrite(LED_BUILTIN, HIGH); // turn the LED on (HIGH is the voltage level)
  delay(1000);                     // wait for a second
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED off by making the voltage LOW
  delay(1000);                     // wait for a second
  digitalWrite(LED_BUILTIN, HIGH); // turn the LED on (HIGH is the voltage level)
  delay(1000);                     // wait for a second
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED off by making the voltage LOW
  delay(1000);                     // wait for a second
  digitalWrite(LED_BUILTIN, HIGH); // turn the LED on (HIGH is the voltage level)
  delay(1000);                     // wait for a second

}




void loop()
{
//  if (ii == 1 && digitalRead(HEAD_HOME) == LOW) {
//    head_stop();
//  }
//  if (ii == 1 && digitalRead(VALVE_HOME) == LOW) {
//    valve_stop();
//  }
//  ii=0;
  calendarcheck();
  digitalWrite(LED_BUILTIN, LOW);
  if (manager.available()) {
    uint8_t len = sizeof(recv_buf);
    uint8_t from;
    if (manager.recvfromAck(recv_buf, &len, &from)) {
      Serial.println("--------");
      Serial.println((char*) recv_buf);
      if (!manager.sendtoWait(receive, sizeof(receive), from)) {
        Serial.println("sendback failed\n");
      }
      memset(message, 0, sizeof(message));
      pointer = message;
      int i = 0;
      while (recv_buf[i + 1])
      {
        //sprintf(message, "%x", outStr[i]);
        mes = (char)recv_buf[i + 1];
        message[i] = mes;
        i++;
      }
      Serial.print(message);
      Serial.print("\r\n");
      if (!strncmp(message, "rt", 2))
      {
        if (head_state == IDLING && valve_state != CYCLINGSTART) {
          rt = atoi(message + 3);
          Serial.print("Receive rt ");
          Serial.println(rt);
          head_prepare(rt, DEFAULT_HEAD_SPEED, 1);
          rotate(RUNNING);
        }

      }
      else if (!strncmp(message, "of", 2))
      {
        if (valve_state == IDLING && head_state != CYCLINGSTART) {
          of = atoi(message + 3);
          if (of > 2220) {
            of = 2220;
          }
          if (of < 0) {
            of = 0; 
          }
          Serial.print("Receive of ");
          Serial.println(of);
          valve_prepare(of, DEFAULT_VALVE_SPEED);
          operate(RUNNING);
        }

      }
      else if (!strncmp(message, "bi", 2))
      {
        if (head_state == IDLING && valve_state == IDLING) {
          pointer = pointer + 3;
          rt = atoi(pointer);
          uint16_t pos = strstr(message, ",") - message;
          of = atoi(pointer + pos + 1);
          message[pos] = '\0';
          Serial.print("Receive bi ");
          Serial.print(rt);
          Serial.println(of);
          head_prepare(rt, DEFAULT_HEAD_SPEED, 1);
          valve_prepare(of, DEFAULT_VALVE_SPEED);
          rotate(RUNNING);
          operate(RUNNING);
        }

      }
      else if (!strncmp(message, "bs", 2))
      {
        if (head_state == IDLING && valve_state == IDLING) {
          Serial.println("Receive bs");
          head_stop();
          valve_stop();
        }

      }
      else if (!strncmp(message, "sf", 2))
      {
        if (valve_state == IDLING && head_state != CYCLINGSTART) {
          Serial.println("Receive sf");
          valve_stop();
        }

      }
      else if (!strncmp(message, "hh", 2))
      {
        if (head_state == IDLING && valve_state != CYCLINGSTART) {
          Serial.println("Receive hh");
          head_stop();
        }

      }
      else if (!strncmp(message, "sc", 2))
      { //Single Cycle without weather station
        if (head_state == IDLING && valve_state == IDLING)
        {
          uint16_t area = atoi(pointer + 3);
          pre_level = atoi(pointer + 8);
          int angle1 = 0;
          int angle2 = 0;
          for (uint16_t a = 0; a < 370; a++) {
            flow_que[a] = 0;
          }
          Serial.println(area);
          Serial.println(pre_level);
          readarea(area, &angle1, &angle2);
          if (angle2 < angle1)
          {
            angle1 = angle1 - 360;
          }
          for (int b = 0; b < 370; b++) {
            Serial.println(flow_que[b]);
          }

          for (uint16_t a = 0; a < 363; a = a + 10) {
            Serial.println(a);
            for (uint16_t i = 0; i < 10; i++) {
              Serial.print(flow_que[a + i]);
              Serial.print(".");
            }
          }
          Serial.println("angle 1:");
          Serial.println(angle1);
          Serial.println("angle 2:");
          Serial.println(angle2);

          cycle(angle1, angle2);
        }
      }
      else if (!strncmp(message, "af", 2))
      { //recv area fragment
        if (head_state == IDLING && valve_state == IDLING)
        {
          uint16_t buff = (((message[2] << 8) + message[3]) & 0x1ffe) >> 1;
          //        Serial.println(buff);
          uint16_t len =  (((message[4] << 8) + message[5]) & 0x1ffe) >> 1;
          //        Serial.println(len);
          for (uint16_t i = 0; i < len; i = i + 1)
          {
            flow_que[buff + i] = (((message[6 + i * 2] << 8) + message[7 + i * 2]) & 0x1ffe) >> 1;
//             if (flow_que[buff + i] > 2220){
//                 flow_que[buff + i] = 2220;
//             }
                      Serial.println(flow_que[buff + i]);
          }
        }
      }
      else if (!strncmp(message, "as", 2))
      { //recv area save
        Serial.println("receive as");
        savearea();
      }
      else if (!strncmp(message, "ca", 2))
      { //calendar add}

        uint16_t t = (((message[2] << 8) + message[3]) & 0x7ffe) >> 1;
        uint16_t a = (((message[4] << 8) + message[5]) & 0x7ffe) >> 1;
        uint16_t ct = (((message[6] << 8) + message[7]) & 0x7ffe) >> 1;
        uint16_t plv = message[8];
        Serial.println("------");
        Serial.println(t);
        Serial.println("------");
        Serial.println(a);
        Serial.println("------");
        Serial.println(ct);
        Serial.println("--------");
        Serial.println(plv);

        clock_counter = ct;

        calendaradd(t, a, plv);
        timesynchr(ct);
      }
      else if (!strncmp(message, "cd", 2))
      { //calendar add}
        uint16_t t = (((message[2] << 8) + message[3]) & 0x7ffe) >> 1;
        Serial.println(t);
        calendardel(t);
      }
      else if (!strncmp(message, "ts", 2)) {
        uint16_t t = (((message[2] << 8) + message[3]) & 0x7ffe) >> 1;
        Serial.println(t);
        timesynchr(t);

      }
      else if (!strncmp(message, "rs", 2)) {
        resetflash();
      }
    }
  }
}


void ioinit()
{
  //Set PinMode
  pinMode(HEAD_SLEEP, OUTPUT);
  //pinMode(HEAD_STEP, OUTPUT);
  head_sleep();
  pinMode(HEAD_DIR, OUTPUT);
  pinMode(HEAD_HOME, INPUT);

  pinMode(VALVE_SLEEP, OUTPUT);
  //pinMode(VALVE_STEP, OUTPUT);
  valve_sleep();
  pinMode(VALVE_DIR, OUTPUT);
  pinMode(VALVE_HOME, INPUT);

  pinMode(LED_BUILTIN, OUTPUT);

  //Set initial Pin output
  digitalWrite(HEAD_SLEEP, LOW);
  //digitalWrite(HEAD_STEP,LOW);
  digitalWrite(HEAD_DIR, LOW);

  digitalWrite(VALVE_SLEEP, LOW);
  //digitalWrite(VALVE_STEP,LOW);
  digitalWrite(VALVE_DIR, LOW);

  // Configure PA18 (D10 on Arduino Zero) to be output
  PORT->Group[PORTA].DIRSET.reg = PORT_PA18; // Set pin as output
  PORT->Group[PORTA].OUTCLR.reg = PORT_PA18; // Set pin to low

  // Enable the port multiplexer for PA18
  PORT->Group[PORTA].PINCFG[18].reg |= PORT_PINCFG_PMUXEN;
  PORT->Group[PORTA].PMUX[9].reg = PORT_PMUX_PMUXE_E;

  // Configure PB08 (A1 on Arduino Zero) to be output
  PORT->Group[PORTB].DIRSET.reg = PORT_PB08; // Set pin as output
  PORT->Group[PORTB].OUTCLR.reg = PORT_PB08; // Set pin to low

  // Enable the port multiplexer for PB08
  PORT->Group[PORTB].PINCFG[8].reg |= PORT_PINCFG_PMUXEN;
  PORT->Group[PORTB].PMUX[4].reg = PORT_PMUX_PMUXE_E;
}

void set_head_dir()
{
  if (head_dir == CLOCKWISE)
  {
    HEAD_CLOCKWISE;
  }
  else
  {
    HEAD_COUNTERCLOCKWISE;
  }
}

void set_valve_dir()
{
  if (valve_dir == CLOCKWISE)
  {
    VALVE_CLOCKWISE;
  }
  else
  {
    VALVE_COUNTERCLOCKWISE;
  }
}

void start_head_timer()
{
  REG_GCLK_CLKCTRL = (uint16_t)(GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID_TCC2_TC3);
  head_TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;
  head_TC->CTRLA.reg |= TC_CTRLA_MODE_COUNT16;
  head_TC->CTRLA.reg |= TC_CTRLA_WAVEGEN_MFRQ;
  head_TC->CTRLA.reg |= TC_CTRLA_PRESCALER_DIV64;
  head_TC->COUNT.reg = 0;
  head_TC->INTENSET.reg = 0;
  head_TC->INTENSET.bit.MC0 = 1;
  NVIC_EnableIRQ(TC3_IRQn);
  head_TC->CTRLA.reg |= TC_CTRLA_ENABLE;
}

void start_valve_timer()
{
  REG_GCLK_CLKCTRL = (uint16_t)(GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID_TC4_TC5);
  valve_TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;
  valve_TC->CTRLA.reg |= TC_CTRLA_MODE_COUNT16;
  valve_TC->CTRLA.reg |= TC_CTRLA_WAVEGEN_MFRQ;
  valve_TC->CTRLA.reg |= TC_CTRLA_PRESCALER_DIV64;
  valve_TC->COUNT.reg = 0;
  valve_TC->INTENSET.reg = 0;
  valve_TC->INTENSET.bit.MC0 = 1;
  NVIC_EnableIRQ(TC4_IRQn);
  valve_TC->CTRLA.reg |= TC_CTRLA_ENABLE;
}

void head_prepare(int angle, uint16_t h_speed, uint16_t dir_check)
{

  //Init head position and state, ready for rotating!
  head_degree = 0;
  head_target = angle;
  head_total_step = angle - head_pos;
  head_v = h_speed;
  Serial.println("ck:");
  Serial.println(head_pos);
  Serial.println(angle);
  Serial.println(head_target);
  Serial.println(head_total_step);
  //Check direction and degree~~
  uint16_t pre_dir = head_dir;
  if (dir_check == 1)
  { //General case, check shortest path
    if (head_total_step < -180)
    {
      head_dir = OPEN_DIR;
      head_total_step = 360 + head_total_step;
    }
    else if (head_total_step < 0)
    {
      head_dir = CLOSE_DIR;
      head_total_step = -head_total_step;
    }
    else if (head_total_step < 180)
    {
      head_dir = OPEN_DIR;
    }
    else
    {
      head_dir = CLOSE_DIR;
      head_total_step = 360 - head_total_step;
    }
  }
  else
  { //Cycle start, only counterclockwise
    head_dir = OPEN_DIR;
    if (head_total_step < 0)
      head_total_step = 360 + head_total_step;
  }
  if (pre_dir != head_dir)
    head_total_step += HEAD_SLACK;
  set_head_dir();
//   Serial.println("rotate:");
//   Serial.println(head_total_step);
}

void valve_prepare(uint16_t valve, uint16_t v_speed)
{

  //Init valve position and state, ready for rotating!
  valve_degree = 0;
  valve_target = valve;
  valve_total_step = abs(valve - valve_pos);
  valve_v = v_speed;

  //Check direction and degree~~
  uint16_t pre_dir = valve_dir;
  if (valve_target >= valve_pos)
  {
    valve_dir = OPEN_DIR;
  }
  else if (valve_target < valve_pos)
  {
    valve_dir = CLOSE_DIR;
  }
  if (valve_dir != pre_dir)
    valve_total_step += VALVE_SLACK;
  set_valve_dir();
}

void rotate(uint16_t state)
{
  if ((head_total_step > 0) || (state == STOP1) || (state == STOP2) || (state == CYCLING))
  {
    head_state = state;
    head_ramp_dowm = STEP_PER_ANGLE - 2 * (DEFAULT_HEAD_sV - head_v);
    head_degree = 0;
    head_step_count = 0;
    head_half_cycle = DEFAULT_HEAD_sV;
    start_head_timer();
    head_awake();
  }
}

void operate(uint16_t state)
{
  if ((valve_total_step > 0) || (state == STOP1) || (state == STOP2))
  {
    valve_state = state;
    if (valve_state != STOP1)
    {
      if (valve_total_step < ceil(2 * (DEFAULT_VALVE_sV - valve_v) * acl_count_max / STEP_PER_DEGREE))
      {
        valve_ramp_up_deg = (uint16_t)(valve_total_step / 2);
        valve_ramp_down_deg = valve_total_step - valve_ramp_up_deg;
      }
      else
      {
        valve_ramp_up_deg = (uint16_t)((DEFAULT_VALVE_sV - valve_v) * acl_count_max / STEP_PER_DEGREE);
        valve_ramp_down_deg = valve_total_step - valve_ramp_up_deg;
      }
    }
    valve_step_count = 0;
    valve_half_cycle = DEFAULT_VALVE_sV;
    start_valve_timer();
    valve_awake();
  }
}

void head_stop()
{
  if (HEAD_HOME_FLAG)
  {
    head_prepare(head_pos + HEAD_POS_COUNT * 2, HEAD_V_HOME, 1);
    rotate(STOP2);
  }
  else
  {
    head_dir = CLOSE_DIR;
    set_head_dir();
    head_v = HEAD_V_HOME;
    rotate(STOP1);
  }
}
void valve_stop()
{
  if (VALVE_HOME_FLAG)
  {
    valve_prepare(valve_pos + VALVE_POS_COUNT * 2, VALVE_V_HOME);
    operate(STOP2);
  }
  else
  {
    valve_dir = CLOSE_DIR;
    set_valve_dir();
    valve_v = VALVE_V_HOME;
    operate(STOP1);
  }
  valve_home_step_count = 0;
  valve_home_degree = 0;
  valve_reset_flag = 0;
}

void cycle(int angle1, int angle2)
{
  Serial.println(angle1);
  Serial.println(angle2);
  valve_home_deg_shut = 0;
  if (angle1 == 0 && angle2 == 359) {
    cycle_reverse = true;
  }
  cycle_start = angle1;
  cycle_end = angle2;
  head_cycle_target = angle2;
  head_prepare(angle1, DEFAULT_HEAD_SPEED, 1);
  rotate(CYCLINGSTART);
}

void flow_que_update(uint16_t length, char message[])
{
  memset(flow_que, '\0', FLOW_QUEUE_LENGTH);
  uint16_t i;
  uint16_t of;
  uint16_t diff;
  char degree[3]; //TODO:*****************************************************************************
  for (i = 0; i < length; i++)
  {
    if (i == 0)
    {
      of = message[0] * 100 + message[1];
      flow_que[0] = of;
      //Serial.println(of);
    }
    else
    {
      diff = message[i + 1];
      if (diff <= 127)
      {
        flow_que[i] = flow_que[i - 1] + diff;
      }
      else
      {
        flow_que[i] = flow_que[i - 1] + diff - 255;
      }
      //Serial.println(flow_que[i]);
    }
  }
}

void TC3_Handler()
{
  if (head_TC->INTFLAG.bit.MC0 == 1)
  {
    head_TC->INTFLAG.bit.MC0 = 1;
    if (head_state == STOP1)
    { //Finding home
      head_counter = 0;
      for (int i = 0; i < MAX_HOME_COUNTER; i++) {
        if (HEAD_HOME_FLAG) {
          head_counter = head_counter + 1;
        }
      }
      if (head_counter >= MAX_HOME_COUNTER) {
        head_pos = HEAD_POS_COUNT;
        head_prepare(0, HEAD_V_HOME, 1);
        rotate(RUNNING);
      }
      else if (head_half_cycle > HEAD_V_HOME)
      {
        head_half_cycle = head_half_cycle - 1;
      }
      //      if (HEAD_HOME_FLAG)
      //      {
      //        Serial.println("HEAD HANDLER 1");
      //        head_pos = HEAD_POS_COUNT;
      //        head_prepare(0, HEAD_V_HOME, 1);
      //        rotate(RUNNING);
      //      }

    }
    else if (head_degree >= head_total_step)
    { //Reach target degree
      Serial.println("Reach target");
      if (head_state == STOP2)
      {
        head_dir = CLOSE_DIR;
        set_head_dir();
        head_state = STOP1;
      }
      else if (head_state == CYCLING)
      {
        if (pre_level == 1) {
          Serial.println("pre == 1");
          head_sleep();
          head_TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;

          head_TC->CTRLA.reg &= ~TC_CTRLA_WAVEGEN_MFRQ;
          head_TC->COUNT.reg = 0;
          head_TC->INTENCLR.reg = 0;
          head_TC->INTENCLR.bit.MC0 = 1;
          NVIC_DisableIRQ(TC3_IRQn);

          head_state = CYCLINGEND;
          delay(10);
          if (valve_state == IDLING)
          {
            valve_stop();
          }
          else if (valve_degree < valve_ramp_down_deg)
          {
            valve_degree = valve_ramp_down_deg;
            valve_step_count = 0;
          }
          //normal
        } else {
          Serial.println("pre != 1");
          pre_level -= 1;
          head_degree = 0;
          head_step_count = 0;
          head_pos = head_target;
          if (cycle_reverse) {
            head_pos = cycle_start;
          } else {
            if (head_dir == CLOSE_DIR) {
              head_dir = OPEN_DIR;
              head_target = cycle_end;
            } else {
              head_dir = CLOSE_DIR;
              head_target = cycle_start;
            }
            set_head_dir();
          }
        }
      }
      else
      {
        head_sleep();
        head_TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;

        head_TC->CTRLA.reg &= ~TC_CTRLA_WAVEGEN_MFRQ;
        head_TC->COUNT.reg = 0;
        head_TC->INTENCLR.reg = 0;
        head_TC->INTENCLR.bit.MC0 = 1;
        NVIC_DisableIRQ(TC3_IRQn);

        head_degree = 0;
        head_pos = head_target;
        head_target = 0;
        head_total_step = 0;
        head_ramp_dowm = 0;
        head_step_count = 0;
        pre_level = 1;
        if (head_state == CYCLINGSTART)
        {
          head_state = IDLING;

          valve_prepare(flow_que[0], DEFAULT_VALVE_SPEED);
          operate(CYCLINGSTART);
        }
        else
        {
          head_state = IDLING;
        }
      }
    }
    else
    { //During running or cycling
      head_step_count++;
      //if ((head_step_count & 1) == 0){
      if ((valve_state == IDLING) || (head_state != CYCLING))
      {
        if ((head_degree == 0) && (head_half_cycle > head_v))
        {
          head_half_cycle = head_half_cycle - HEAD_RAMP;
        }
        else if ((head_degree == head_total_step - 1) && (head_step_count >= head_ramp_dowm))
        {
          head_half_cycle = head_half_cycle + HEAD_RAMP;
        }
        else if (head_half_cycle > head_v)
        {
          head_half_cycle = head_half_cycle - HEAD_RAMP;
        }
      }
      else if ((head_state == CYCLING) && (head_half_cycle < DEFAULT_HEAD_sV))
      {
        head_half_cycle = head_half_cycle + HEAD_RAMP;
      }

      if (head_step_count >= STEP_PER_ANGLE)
      {
        head_step_count = 0;
        head_degree++;
        //Serial.println(head_degree);
        if ((head_state == CYCLING) && (valve_state == IDLING))
        {
          //Serial.println(flow_que[head_degree]);
           if (head_dir == OPEN_DIR) {
             valve_prepare(flow_que[head_degree], DEFAULT_VALVE_SPEED);
           } else {
             valve_prepare(flow_que[cycle_end - cycle_start - head_degree], DEFAULT_VALVE_SPEED);
           }
          operate(RUNNING);
        }
      }
      //}
    }
  }
}

void TC4_Handler()
{
  if (valve_TC->INTFLAG.bit.MC0 == 1)
  {
    valve_TC->INTFLAG.bit.MC0 = 1;

    if (valve_state == STOP1)
    {
      valve_counter = 0;
      for (int j = 0; j < MAX_HOME_COUNTER; j++) {
        if (VALVE_HOME_FLAG) {
          valve_counter = valve_counter + 1;
        }
      }
      if (valve_counter >= MAX_HOME_COUNTER) {
        valve_pos = VALVE_POS_COUNT;
        //valve_pos = VALVE_POS_COUNT;
        valve_prepare(0, VALVE_V_HOME);
        if (head_state == CYCLINGEND)
        {
          head_state = IDLING;
          head_stop();
        }
        operate(RUNNING);
      }

      else if ((valve_half_cycle > VALVE_V_HOME) && (valve_reset_flag == 0))
      {
        acl_off_count = acl_off_count + 1;
        if (acl_off_count >= acl_off_count_max){
            acl_off_count = 0;
            valve_half_cycle = valve_half_cycle - 1;
        }
      }
      valve_home_step_count++;
//       Serial.println(" valve_home_step_count++");
//       Serial.println(valve_home_step_count);
      if (valve_home_step_count >= STEP_PER_DEGREE)
          {
            //        Serial.println(valve_home_degree);
            valve_home_step_count = 0;
            valve_home_degree = valve_home_degree + 1;
            if (valve_reset_flag == 1){
                valve_home_deg_shut = valve_home_deg_shut + 1;
            }
          }
      if (valve_home_degree >= 2220)
      {
        //        Serial.println(valve_home_degree);
        valve_home_degree = 0;
        valve_stop();
        valve_reset_flag=1;
        Serial.println("Valve Home Rest");
        valve_half_cycle = VALVE_V_HOME_RESET;
      }
      if (valve_home_deg_shut >= 1500) //after certain steps during home reset, shut down
      {
        //        Serial.println(valve_home_degree);
        valve_home_deg_shut = 0;
        valve_reset_flag=0;
        valve_sleep();
        valve_TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;
        valve_TC->CTRLA.reg &= ~TC_CTRLA_WAVEGEN_MFRQ;
        valve_TC->INTENCLR.reg = 0;
        valve_TC->INTENCLR.bit.MC0 = 1;
        NVIC_DisableIRQ(TC4_IRQn);

        valve_degree = 0;
        valve_pos = valve_target;
        valve_target = 0;
        valve_total_step = 0;
        valve_step_count = 0;
        head_state = IDLING;
        valve_state = IDLING;
        Serial.println("Valve shut down after reset");
      }

      //      if (VALVE_HOME_FLAG)
      //      {
      //        valve_pos = VALVE_POS_COUNT;
      //        //valve_pos = VALVE_POS_COUNT;
      //        valve_prepare(0, VALVE_V_HOME);
      //        if (head_state == CYCLINGEND)
      //        {
      //          head_state = IDLING;
      //          head_stop();
      //        }
      //        operate(RUNNING);
      //      }

    }
    else if (valve_degree >= valve_total_step)
    {
      if (valve_state == STOP2)
      {
        valve_dir = CLOSE_DIR;
        set_valve_dir();
        valve_state = STOP1;
      }
      else
      {
        valve_sleep();
        valve_TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;
        valve_TC->CTRLA.reg &= ~TC_CTRLA_WAVEGEN_MFRQ;
        valve_TC->INTENCLR.reg = 0;
        valve_TC->INTENCLR.bit.MC0 = 1;
        NVIC_DisableIRQ(TC4_IRQn);

        valve_degree = 0;
        valve_pos = valve_target;
        valve_target = 0;
        valve_total_step = 0;
        valve_step_count = 0;
        if (valve_state == CYCLINGSTART)
        {
          valve_state = IDLING;
          head_prepare(head_cycle_target, DEFAULT_HEAD_SPEED, 0);
          rotate(CYCLING);
        }
        else if (head_state == CYCLINGEND)
        {
          valve_stop();
        }
        else
        {
          valve_state = IDLING;
          valve_home_deg_shut = 0;
        }
      }
    }
    else
    {
      valve_step_count = valve_step_count + 1;
      acl_count = acl_count + 1;
      if (acl_count >= acl_count_max){
          acl_count = 0;
          if ((valve_degree >= valve_ramp_down_deg) && (valve_half_cycle < DEFAULT_VALVE_sV))
          {
            valve_half_cycle = valve_half_cycle + VALVE_RAMP;
          }
          else if ((valve_degree < valve_ramp_up_deg) && (valve_half_cycle > valve_v))
          {
            valve_half_cycle = valve_half_cycle - VALVE_RAMP;
          }
      }

      if (valve_step_count >= STEP_PER_DEGREE)
      {
        //        Serial.println(valve_degree);
        valve_step_count = 0;
        valve_degree = valve_degree + 1;
      }

      //    if ((valve_step_count&1) == 0){
      //      if (valve_step_count >= STEP_PER_DEGREE){
      //        valve_step_count = 0;
      //        valve_degree++;
      //      }
      //    }
    }
  }
}

void flashinit()
{
  Serial.println("flash initiate start");

  mySPI.begin();

  pinPeripheral(A3, PIO_SERCOM_ALT);
  pinPeripheral(A4, PIO_SERCOM_ALT);
  pinPeripheral(9, PIO_SERCOM_ALT);

  // SPI.beginTransaction(SPISettings(14000000, MSBFIRST, SPI_MODE0));
  // initalize the  data ready and chip select pins:
  pinMode(CS, OUTPUT);
  pinMode(WP, OUTPUT);
  pinMode(HD, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(8, HIGH);
  digitalWrite(CS, HIGH);
  digitalWrite(WP, HIGH);
  digitalWrite(HD, HIGH);

  Serial.println("flash initiate finished");

}

void readflash(byte *data, uint32_t address)
{
  digitalWrite(CS, LOW);
  mySPI.transfer(READ); //transmit read opcode
  mySPI.transfer((byte)(address >> 16));
  mySPI.transfer((byte)(address >> 8)); //send MSByte address first
  mySPI.transfer((byte)(address));      //send LSByte address

  for (uint16_t i = 0; i < 256 ; i++) {
    data[i] = mySPI.transfer(0xFF); //get data byte
  }
  digitalWrite(CS, HIGH); //release chip, signal end transfer
}
void erase () {

}

void resetflash() {
  digitalWrite(CS, LOW);
  mySPI.transfer(WREN); //write enable
  digitalWrite(CS, HIGH); //disable device
  delay(10);
  digitalWrite(CS, LOW);
  mySPI.transfer(0x60); //erase instruction
  digitalWrite(CS, HIGH); //disable device
  Serial.println("Flash reset successfully.");
}


void writeflash(byte *data, uint32_t address)
{
  Serial.println("WRITE");
  if ( (address & 0b111111111111) == 0) {
    digitalWrite(CS, LOW);
    mySPI.transfer(WREN); //write enable
    digitalWrite(CS, HIGH); //disable device
    delay(10);
    digitalWrite(CS, LOW);
    mySPI.transfer(0x20); //erase instruction
    mySPI.transfer((byte)(address >> 16));
    mySPI.transfer((byte)(address >> 8)); //send MSByte address first
    mySPI.transfer((byte)(address));      //send LSByte address

    digitalWrite(CS, HIGH); //disable device
    //wait for eeprom to finish writing
    delay(100);
    Serial.println("ERASE");

  }

  digitalWrite(CS, LOW);
  mySPI.transfer(WREN); //write enable
  digitalWrite(CS, HIGH); //disable device
  delay(10);
  digitalWrite(CS, LOW);
  mySPI.transfer(WRITE); //write instruction
  mySPI.transfer((byte)(address >> 16));
  mySPI.transfer((byte)(address >> 8)); //send MSByte address first
  mySPI.transfer((byte)(address));      //send LSByte address

  //write 128 bytes
  for (uint16_t I = 0; I < 256; I++)
  {
    mySPI.transfer(data[I]); //write data byte
  }
  digitalWrite(CS, HIGH); //disable device
  //wait for eeprom to finish writing
  delay(10);
}

void readarea(uint16_t area, int *angle1, int *angle2)
{
  uint32_t address = (area << 12);
  byte data[256];
  readflash(data, address);
  *angle1 = (data[0] << 8) + data[1];
  *angle2 = (data[2] << 8) + data[3];
//   if (*angle2 < *angle1)
//   {
//     *angle2 = *angle2 + 360;
//   }
  int pie;
  int j = 0;
  if (*angle2 < *angle1){
    pie = *angle2 - *angle1 + 360 + 1;
  }
  else{
    pie = *angle2 - *angle1 + 1;
  }
  for (int i = 4; (i < 256) && (i < (pie * 2 + 4)); i = i + 2)
  {
    flow_que[j] = (data[i] << 8) + data[i + 1];
    j = j + 1;
  }

  if (j < pie)
  {
    readflash(data, address + 256);
    for (int i = 0; (i < 256) && (i < ((pie - 126) * 2)); i = i + 2)
    {
      flow_que[j] = (data[i] << 8) + data[i + 1];
      j = j + 1;
    }
  }
  if (j < pie)
  {
    readflash(data, address + 512);
    for (int i = 0; (i < 256) && (i < ((pie - 254) * 2)); i = i + 2)
    {
      flow_que[j] = (data[i] << 8) + data[i + 1];
      j = j + 1;
    }
  }
  if (j < pie)
  {
    readflash(data, address + 768);
    for (int i = 0; (i < 256) && (i < ((pie - 254 - 128) * 2)); i = i + 2)
    {
      flow_que[j] = (data[i] << 8) + data[i + 1];
      j = j + 1;
    }
  }

}

void savearea()
{
  uint32_t address = flow_que[0] << 12;
  byte data[256];
  int j = 0;
  uint16_t a = 0;
  uint16_t b = 0;
  int area_length = 0;
  if (flow_que[2] < flow_que[1]){
    area_length = flow_que[2] - flow_que[1] +360 + 4;
  }
  else {
    area_length = flow_que[2] - flow_que[1] + 4;
  }
  for (int i = 1; i < area_length; i++)
  {
    data[j] = (byte)(flow_que[i] >> 8);
    //    Serial.println( data[j]);
    j = j + 1;
    data[j] = (byte)(flow_que[i] & 255);
    //    Serial.println( data[j]);
    j = j + 1;
    if (j == 256)
    {
      j = 0;
      writeflash(data, address);
      address = address + 256;
    }
  }
  writeflash(data, address);
}

uint16_t schedule[64];
uint16_t arealist[64];
uint16_t plvlist[64];
uint16_t maxcycle = 0;
uint16_t nextcycle = 0;

void calendarinit()
{
  lastsystime = millis();
  clock_counter = 0;
  byte data[256];
  readflash(data, 0);
  maxcycle = (uint16_t)data[0];
  if (maxcycle == 255) {
    maxcycle = 0;
  }
  Serial.println("amx cycle: ");
  Serial.println(maxcycle);
  //  Serial.println("cal data:");
  //  for (int k = 0; k < 256; k = k + 16) {
  //    for (int g = 0; g < 16; g++) {
  //      Serial.print(data[k + g]);
  //      Serial.print(".");
  //    }
  //    Serial.print("---");
  //    Serial.println(k);
  //
  //  }
  uint16_t j = 0;
  for (uint16_t i = 1; i < (1 + (maxcycle) * 5); i = i + 5)
  {
    j = j + 1;
    schedule[j] = (data[i] << 8) + data[i + 1];
    arealist[j] = (data[i + 2] << 8) + data[i + 3];
    plvlist[j] = data[i + 4];
    //    j = j + 1;
  }
  Serial.println("init schedule: ");
  for (int k = 0; k < 64; k = k + 8) {
    for (int g = 0; g < 8; g++) {
      Serial.print(schedule[k + g]);
      Serial.print(".");
    }
    Serial.print("---");
    Serial.println(k);
  }
  Serial.println("init area: ");
  for (int k = 0; k < 64; k = k + 8) {
    for (int g = 0; g < 8; g++) {
      Serial.print(arealist[k + g]);
      Serial.print(".");
    }
    Serial.print("---");
    Serial.println(k);
  }

  Serial.println("init plv ");
  for (int k = 0; k < 64; k = k + 8) {
    for (int g = 0; g < 8; g++) {
      Serial.print(plvlist[k + g]);
      Serial.print(".");
    }
    Serial.print("---");
    Serial.println(k);
  }
}

void timesynchr(uint16_t t) {
  clock_counter = t;
  for (int i = 1; i < 63; i++) {
    if (schedule[i - 1] < clock_counter && schedule[i - 1] != 0) {
      if (schedule[i] > clock_counter || schedule[i] == 0) {
        nextcycle = i;
      }
    }
  }
  Serial.println("Next cycle after time syn: ");
  Serial.println(nextcycle);
}

void calendarcheck()
{
  unsigned long interval = millis() - lastsystime;
  unsigned long delta = interval / 60000; //60000
  if (delta > 0)
  {
    clock_counter = clock_counter + delta;
    Serial.println("calendar check");
    Serial.println(clock_counter);
    tailsystime = interval % 60000;
    lastsystime = lastsystime + delta * 60000;
    Serial.println("-----------");
    Serial.println(nextcycle);
    Serial.println(maxcycle);
    Serial.println(schedule[nextcycle]);
    Serial.println("-----------");
    if (clock_counter >= schedule[nextcycle] && schedule[nextcycle] != 0)
    {
      Serial.println(head_state);
      Serial.println(valve_state);
      while (head_state != IDLING || valve_state != IDLING)
      {
        delay(100);
      }
      int angle1 = 0;
      int angle2 = 0;
      readarea(arealist[nextcycle], &angle1, &angle2);
      if (angle2 < angle1)
          {
            angle1 = angle1 - 360;
          }
      pre_level = plvlist[nextcycle];
      Serial.println("calen plv: ");
      Serial.println(pre_level);
      cycle(angle1, angle2);
      Serial.println("calen check angle1: ");
      Serial.println(angle1);
      Serial.println("calen check angle2: ");
      Serial.println(angle2);

      clock_counter = (clock_counter + 1) % 10080;
      nextcycle = (nextcycle + 1) % (maxcycle + 1);
    }
  }
}

void calendaradd(uint16_t t, uint16_t area, uint16_t plv)
{
  if (schedule[maxcycle] < t)
  {
    maxcycle = maxcycle + 1;
    schedule[maxcycle] = t;
    arealist[maxcycle] = area;
    plvlist[maxcycle] = plv;
  }
  else
  {
    uint16_t j = 1;
    while (schedule[j] < t)
    {
      j = j + 1;
    }
    if (schedule[j] == t)
    {
      arealist[j] = area;
      plvlist[j] = plv;
    }
    else
    {
      maxcycle = maxcycle + 1;
      if (j < nextcycle)
      {
        nextcycle = nextcycle + 1;
      }
      for (uint16_t i = maxcycle; i > j; i = i - 1)
      {
        schedule[i] = schedule[i - 1];
        arealist[i] = arealist[i - 1];
        plvlist[i] = plvlist[i - 1];
      }
      //      schedule[maxcycle] = t;
      //      arealist[maxcycle] = area;
      schedule[j] = t;
      arealist[j] = area;
      plvlist[j] = plv;
    }
  }
  byte data[256];
  data[0] = (byte)(maxcycle & 0xff);
  for (uint16_t i = 0; i < maxcycle + 1; i++)
  {
    data[i * 5 + 1] = (byte)(schedule[i + 1] >> 8);
    data[i * 5 + 2] = (byte)(schedule[i + 1] & 0xff);
    data[i * 5 + 3] = (byte)(arealist[i + 1] >> 8);
    data[i * 5 + 4] = (byte)(arealist[i + 1] & 0xff);
    data[i * 5 + 5] = (byte)(plvlist[i + 1] & 0xff);
  }
  writeflash(data, 0);
}

void calendardel(uint16_t t)
{
  uint16_t j = 1;
  while (schedule[j] < t)
  {
    j = j + 1;
  }
  if (j < nextcycle)
  {
    nextcycle = nextcycle - 1;
  }

  for (uint16_t i = j; i <= maxcycle; i = i + 1)
  {
    schedule[i] = schedule[i + 1];
    arealist[i] = arealist[i + 1];
    plvlist[i] = plvlist[i + 1];
  }
  maxcycle = maxcycle - 1;
  byte data[256];
  data[0] = (byte)(maxcycle & 0xff);
  for (uint16_t i = 0; i < maxcycle; i++)
  {
    data[i * 5 + 1] = (byte)(schedule[i + 1] >> 8);
    data[i * 5 + 2] = (byte)(schedule[i + 1] & 0xff);
    data[i * 5 + 3] = (byte)(arealist[i + 1] >> 8);
    data[i * 5 + 4] = (byte)(arealist[i + 1] & 0xff);
    data[i * 5 + 5] = (byte)(plvlist[i + 1] & 0xff);
  }
  writeflash(data, 0);
}

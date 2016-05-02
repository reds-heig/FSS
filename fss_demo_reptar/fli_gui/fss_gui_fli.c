/*****************************************************************
 * fss_gui_fli - interface between qtemu and QuestaSim           *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include "fss_utils_fli.h"
#include "fss_gui_qtemu.h"
#include "cJSON.h"

typedef struct {
    /* FLI -> VHDL model */
    /* SWITCH PB */
    mtiSignalIdT sw_pb_o;
    mtiDriverIdT sw_pb_o_drv;

    /* VHDL model -> FLI */
    /* LEDs */
    mtiSignalIdT fpga_led_i;
    /* 7SEG */
    mtiSignalIdT sp6_7seg1_i;
    mtiSignalIdT sp6_7seg2_i;
    mtiSignalIdT sp6_7seg3_i;
    /* Only digits are handled by qtemu ... those Decimal Points are
       therefore useless */
    mtiSignalIdT sp6_7seg1_dp_i;
    mtiSignalIdT sp6_7seg2_dp_i;
    mtiSignalIdT sp6_7seg3_dp_i;
    /* LCD */
    mtiSignalIdT lcd_db_io;
    mtiDriverIdT lcd_db_io_drv;
    mtiSignalIdT lcd_r_nw_i;
    mtiSignalIdT lcd_rs_i;
    mtiSignalIdT lcd_e_i;
} device_data;

static device_data *dev; /* Set by init. Needed by set_switches ... */

/**
 * configure_signals() - Configure the FLI signals and drivers
 *
 * @dev : device parameters
 * @ports: linked list of ports
 */
static void configure_signals(device_data * const dev,
			      mtiInterfaceListT *ports)
{
    DBG("[%s] Configure signals\n", __FUNCTION__);

    /* FLI -> VHDL model */
    /* SWITCH PB */
    FIND_PORT(dev->sw_pb_o, "SW_PB_o", ports);
    CREATE_DRIVER(dev->sw_pb_o_drv, dev->sw_pb_o);
    /* VHDL model -> FLI */
    /* LEDs */
    FIND_PORT(dev->fpga_led_i, "FPGA_LED_i", ports);
    /* 7SEG */
    FIND_PORT(dev->sp6_7seg1_i, "SP6_7seg1_i", ports);
    FIND_PORT(dev->sp6_7seg2_i, "SP6_7seg2_i", ports);
    FIND_PORT(dev->sp6_7seg3_i, "SP6_7seg3_i", ports);
    FIND_PORT(dev->sp6_7seg1_dp_i, "SP6_7seg1_DP_i", ports);
    FIND_PORT(dev->sp6_7seg2_dp_i, "SP6_7seg2_DP_i", ports);
    FIND_PORT(dev->sp6_7seg3_dp_i, "SP6_7seg3_DP_i", ports);
    /* LCD */
    FIND_PORT(dev->lcd_db_io, "LCD_DB_io", ports);
    CREATE_DRIVER(dev->lcd_db_io_drv, dev->lcd_db_io);
    FIND_PORT(dev->lcd_r_nw_i, "LCD_R_nW_i", ports);
    FIND_PORT(dev->lcd_rs_i, "LCD_RS_i", ports);
    FIND_PORT(dev->lcd_e_i, "LCD_E_i", ports);
}

/**
 * initialize_signals() - Initialize the simulation's signals
 *
 * @dev: device parameters
 */
static void initialize_signals(const device_data * const dev)
{
    char tmp_buf[8]; /* Temporary buffer used for char->binary conversion */

    DBG("[%s] Initialize signals\n", __FUNCTION__);

    /* switches. 0 = idle. */
    convert_char_to_logic_vector(0, 8, tmp_buf); /* fill vector with STD_LOGIC_0s */
    mti_ScheduleDriver(dev->sw_pb_o_drv, (long)(tmp_buf), 0, MTI_INERTIAL);
}

/**
 * led_handler() - order qtemu to set LED state according to VHDL signals
 *
 * @param: pointer to the instance information structure casted in a void type
 */
static void led_handler(void * const param)
{
    device_data *dev = (device_data *)param;
    char led_value;
    cJSON *root;

    /* Will be deleted when removed from queue after processing */
    root = cJSON_CreateObject();

    led_value = convert_logic_vector_to_char(dev->fpga_led_i);

    /* Send JSON to qtemu */
    DBG("[%s] LED: sending 0x%02x\n", __FUNCTION__, led_value);
    cJSON_AddStringToObject(root, "perif", PERID_LED);
    cJSON_AddNumberToObject(root, "value", (unsigned int)led_value);
    sp6_emul_cmd_post(root);
}

/**
 * sevenseg_handler() - order qtemu to set 7SEG state according to VHDL signals
 *
 * @param: pointer to the instance information structure casted in a void type
 */
static void sevenseg_handler(void * const param)
{
    device_data *dev = (device_data *)param;
    char sevenseg_val[3];
    cJSON *root;

    /*
       Apparently, only digits 0 to 9 are handled. Everything else
       (DP included?) isn't implemented.
       No need to check for implemented values, qtemu will ignore everything
       that's not a digit.

       See qtemu's qtemureptar.cpp :

       const int char2segments[10] = {
       0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
       };
     */

    /* Be lazy, update all three 7seg even if only one changed state. */
    sevenseg_val[0] = convert_logic_vector_to_char(dev->sp6_7seg1_i);
    sevenseg_val[1] = convert_logic_vector_to_char(dev->sp6_7seg2_i);
    sevenseg_val[2] = convert_logic_vector_to_char(dev->sp6_7seg3_i);

    /* Send JSON to qtemu */
    DBG("[%s] 7SEG#%d: sending 0x%02x\n", __FUNCTION__, 1, sevenseg_val[0]);
    /* Will be deleted when removed from queue after processing */
    root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "perif", PERID_SEVEN_SEG);
    cJSON_AddNumberToObject(root, "digit", 1);
    cJSON_AddNumberToObject(root, "value", (unsigned)sevenseg_val[0]);
    sp6_emul_cmd_post(root);

    DBG("[%s] 7SEG#%d: sending 0x%02x\n", __FUNCTION__, 2, sevenseg_val[1]);
    /* Will be deleted when removed from queue after processing */
    root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "perif", PERID_SEVEN_SEG);
    cJSON_AddNumberToObject(root, "digit", 2);
    cJSON_AddNumberToObject(root, "value", (unsigned)sevenseg_val[1]);
    sp6_emul_cmd_post(root);

    DBG("[%s] 7SEG#%d: sending 0x%02x\n", __FUNCTION__, 3, sevenseg_val[2]);
    /* Will be deleted when removed from queue after processing */
    root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "perif", PERID_SEVEN_SEG);
    cJSON_AddNumberToObject(root, "digit", 3);
    cJSON_AddNumberToObject(root, "value", (unsigned)sevenseg_val[2]);
    sp6_emul_cmd_post(root);
}

/**
 * lcd_handler() - not implemented yet
 *
 * @param: pointer to the instance information structure casted in a void type
 */
static void lcd_handler(void * const param)
{
    /* TODO */
    DBG("[%s] LCD pin changed. Ignoring (LCD not implemented).\n", __FUNCTION__);
}

/**
 * quit_callback() - Callback invoked on quit
 *
 * @param: pointer to the instance information structure casted in a void type
 */
static void quit_callback(void * const param)
{
    device_data *dev = (device_data *)param;

    DBG("[%s] Device END\n", __FUNCTION__);

    /* terminate gui threads */
    sp6_emul_exit();

    /* Free private data */
    mti_Free(dev);
}

/**
 * restart_callback() - Callback invoked on simulation's end or restart
 *
 * @param: pointer to the instance information structure casted in a void type
 */
static void restart_callback(void * const param)
{
    device_data *dev = (device_data *)param;

    /* Re-initialize signals */
    initialize_signals(dev);

    DBG("[%s] Device RESTART\n", __FUNCTION__);
}

/**
 * fss_gui_init() - FLI initialization routine
 *
 * @region  : region in design for this instance
 * @param   : last part of the string in foreign attributes
 * @generics: linked list of generic values
 * @ports   : linked list of ports
 *
 */
void fss_gui_init(mtiRegionIdT region,
		  char *param,
		  mtiInterfaceListT *generics,
		  mtiInterfaceListT *ports)
{
    mtiProcessIdT device_proc;     /* ISR process handle */

    dev = (device_data *)mti_Malloc(sizeof(device_data));

    configure_signals(dev, ports);
    initialize_signals(dev);

    /* Each process is combinatorial and handles a set of inputs */
    /* LED process */
    CREATE_PROCESS(device_proc, "<FSS_gui_led>", led_handler, dev);
    mti_Sensitize(device_proc, dev->fpga_led_i, MTI_EVENT);
    /* 7seg process */
    CREATE_PROCESS(device_proc, "<FSS_gui_7seg>", sevenseg_handler, dev);
    mti_Sensitize(device_proc, dev->sp6_7seg1_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->sp6_7seg2_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->sp6_7seg3_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->sp6_7seg1_dp_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->sp6_7seg2_dp_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->sp6_7seg3_dp_i, MTI_EVENT);
    /* LCD process */
    CREATE_PROCESS(device_proc, "<FSS_gui_lcd>", lcd_handler, dev);
    mti_Sensitize(device_proc, dev->lcd_db_io, MTI_EVENT);
    mti_Sensitize(device_proc, dev->lcd_r_nw_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->lcd_rs_i, MTI_EVENT);
    mti_Sensitize(device_proc, dev->lcd_e_i, MTI_EVENT);

    /* Switches (output) are simulated in separate thread (see
       fss_gui_qtemu.c) */

    /* Gui start */
    sp6_emul_init();

    /* Set callbacks */
    mti_AddQuitCB(quit_callback, dev);
    mti_AddRestartCB(restart_callback, dev);
}

/**
 * set_switches_state() - Set the state of the switches
 *
 * @state: desired satte
 */
void set_switches_state(int state)
{
    char tmp_buf[8];

    DBG("[%s] SWITCHES: receiving 0x%02x\n", __FUNCTION__, state);
    convert_char_to_logic_vector(state , 8, tmp_buf);
    mti_ScheduleDriver(dev->sw_pb_o_drv, (long)tmp_buf, 0, MTI_INERTIAL);
}

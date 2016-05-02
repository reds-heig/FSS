/*****************************************************************
 * fss_utils_fli - Common definitions and macros                 *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include "fss_utils_fli.h"

/**
 * convert_logic_vector_to_char() - Convert a multibit signal into the
 *                                  corresponding numerical value
 *
 * @vec: std_logic_vector signal to convert
 *
 * Return: 8-bit char equivalent to the input signal
 */
char convert_logic_vector_to_char(mtiSignalIdT vec)
{
    mtiSignalIdT *elems_list;
    mtiTypeIdT sig_type;
    mtiInt32T num_elems;
    char data;
    int i;

    /* Get an handle to the type of the given signal */
    sig_type = mti_GetSignalType(vec);
    /* Get the number of elements that compose the vector */
    num_elems = mti_TickLength(sig_type);

    assert(num_elems <= 8);

    /* Extract the list of individual elements */
    elems_list = mti_GetSignalSubelements(vec, 0);

    data = 0;
    for (i = 0; i < num_elems; ++i) {
	/* If a 1 is received, increment the corresponding bit of the
	   result */
	if (mti_GetSignalValue(elems_list[i]) == STD_LOGIC_1) {
	    data += 1 << (num_elems - i - 1);
	}
    }

    mti_VsimFree(elems_list);
    return data;
}

/**
 * convert_logic_vector_to_int() - Convert a multibit signal into the
 *                                 corresponding numerical value
 *
 * @vec: std_logic_vector signal to convert
 *
 * Return: 32-bit integer equivalent to the input signal
 */
int convert_logic_vector_to_int(mtiSignalIdT vec)
{
    mtiSignalIdT *elems_list;
    mtiTypeIdT sig_type;
    mtiInt32T num_elems;
    int data;
    int i;

    /* Get an handle to the type of the given signal */
    sig_type = mti_GetSignalType(vec);
    /* Get the number of elements that compose the vector */
    num_elems = mti_TickLength(sig_type);

    assert(num_elems <= 25);

    /* Extract the list of individual elements */
    elems_list = mti_GetSignalSubelements(vec, 0);

    data = 0;
    for (i = 0; i < num_elems; ++i) {
	/* If a 1 is received, increment the corresponding bit of the
	   result */
	if (mti_GetSignalValue(elems_list[i]) == STD_LOGIC_1) {
	    data += 1 << (num_elems - i - 1);
	}
    }

    mti_VsimFree(elems_list);
    return data;
}

/**
 * convert_char_to_logic_vector() - Convert a char value, with at most 8
 *                                  significant bits, into its binary
 *                                  representation over a character array
 *
 * @c           : char value to convert
 * @n           : number of bits to consider (values in [1, 8])
 * @logic_vector: vector that will hold the corresponding binary representation
 *
 * @note: The given binary representation is not composed by 0s and 1s, but by
 *        STD_LOGIC_0s and STD_LOGIC_1s
 */
void convert_char_to_logic_vector(char c,
				  const size_t n,
				  char * const logic_vector)
{
    int i;

    assert(n >= 1 && n <= 8);

    /* Progressively shift the value to convert, and select logic 1s and 0s
       accordingly */
    for (i = n-1; i >= 0; --i) {
	logic_vector[i] = (c & 1) && (i <= n - 1) ? STD_LOGIC_1 : STD_LOGIC_0;
	c >>= 1;
    }
}

/**
 * convert_int_to_logic_vector() - Convert an integer value value, with at most
 *                                 32 significant bits, into its binary
 *                                 representation over a character array
 *
 * @c           : integer value to convert
 * @n           : number of bits to consider (values in [1, 32])
 * @logic_vector: vector that will hold the corresponding binary representation
 *
 * @note: The given binary representation is not composed by 0s and 1s, but by
 *        STD_LOGIC_0s and STD_LOGIC_1s
 */
void convert_int_to_logic_vector(int c,
				 const size_t n,
				 char * const logic_vector)
{
    int i;

    assert(n >= 1 && n <= 32);

    /* Progressively shift the value to convert, and select logic 1s and 0s
       accordingly */
    for (i = n-1; i >= 0; --i) {
	logic_vector[i] = (c & 1) && (i <= n - 1) ? STD_LOGIC_1 : STD_LOGIC_0;
	c >>= 1;
    }
}

/**
 * alloc_cmd() - Allocate a command entry
 *
 * @cmd: element to allocate
 *
 * Return: Created entry, which is a deep copy of the one passed as argument,
 *         or NULL in case of malloc() failure
 */
gdsl_element_t alloc_cmd(void *cmd)
{
    command *c = (command *)cmd;
    command *ret = (command *)malloc(sizeof(command));

    assert(cmd != NULL);
    assert(ret != NULL);

    memcpy(ret, c, sizeof(command));

    return (gdsl_element_t)ret;
}

/**
 * free_cmd() - Free the memory associated to a command entry
 *
 * @e: element to free
 */
void free_cmd(gdsl_element_t e)
{
    free(e);
}

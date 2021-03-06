#include "DropletUtils.h"
#include "R_ext/Rdynload.h"
#include "R_ext/Visibility.h"

#define REGISTER(x, i) {#x, reinterpret_cast<DL_FUNC>(x), i}

extern "C" {

static const R_CallMethodDef all_call_entries[] = {
    REGISTER(downsample_matrix, 3),
    REGISTER(downsample_runs, 4),

    REGISTER(compute_multinom, 3),
    REGISTER(montecarlo_pval, 8),

    REGISTER(find_swapped, 6),

    REGISTER(get_cell_barcodes, 3),
    REGISTER(encode_sequences, 1),
    REGISTER(group_cells, 2),

    {NULL, NULL, 0}
};

void attribute_visible R_init_DropletUtils(DllInfo *dll) {
    R_registerRoutines(dll, NULL, all_call_entries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    R_forceSymbols(dll, TRUE);
}

}

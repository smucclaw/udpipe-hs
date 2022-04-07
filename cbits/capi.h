#include "common.h"
#include "model/model.h"
#include "model/pipeline.h"

#include <sstream>
#include <iostream>

using namespace ufal::udpipe;

extern "C" {

model* load_model(char* filename) ;
void free_model(model* m) ;

bool run_pipeline(model* m, const string& input_type, const string& tagger, const string& parser, const string& output_type, 
                    std::istream& input_stream, std::ostream& output_stream) ;

const char* run_pipeline_simple(model* m, char* input) ;

void free_cstr(char* cstr);

}

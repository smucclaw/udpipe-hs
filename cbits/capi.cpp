#include "common.h"
// #include "model/evaluator.h"
#include "model/model.h"
#include "model/pipeline.h"
// #include "sentence/input_format.h"
// #include "sentence/output_format.h"
// #include "tokenizer/detokenizer.h"
// #include "trainer/trainer.h"
// #include "utils/getpara.h"
// #include "utils/iostreams.h"
// #include "utils/options.h"
// #include "utils/process_args.h"
// #include "version/version.h"

#include <sstream>
#include <iostream>

using namespace ufal::udpipe;

extern "C" {

model* load_model(char* filename) {
  return model::load(filename);
}

void free_model(model* m) {
  delete m;
}

// pipeline* make_pipeline(model* m, char* input, char* tagger, char* parser, char* output) {
//   auto pl = new pipeline(m, input, tagger, parser, output);
//   return pl;
//   return reinterpret_cast<pipeline*>(pl);
// }

bool run_pipeline(model* m, const string& input_type, const string& tagger, const string& parser, const string& output_type, 
                    std::istream& input_stream, std::ostream& output_stream) {
  pipeline pipeline(m, input_type, tagger, parser, output_type);
  string error;
  return pipeline.process(input_stream, output_stream, error);
}

const char* run_pipeline_simple(model* m, char* input) {
  std::stringstream instream(input);
  std::ostringstream outstream;
  run_pipeline(m, "tokenize", pipeline::DEFAULT, pipeline::DEFAULT, "conllu", instream, outstream);
  string str = outstream.str();
  char * cstr = new char [str.length()+1];
  std::strcpy (cstr, str.c_str());
  return cstr;
}

void free_cstr(char* cstr) {
  delete[] cstr;
}


}

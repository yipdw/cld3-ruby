# Copyright 2017 Akihiko Odaki <akihiko.odaki.4i@stu.hosei.ac.jp>
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#==============================================================================

require "mkmf"

def ln_fallback(source, destination)
  puts "ln_fallback: #{source} -> #{destination}"
  FileUtils.cp(source, destination)
end

# Check pkg-config first to inform the library is missing if so.
pkg_config("protobuf") or abort "Failed to locate protobuf"

FileUtils.mkdir_p("cld_3/protos")
FileUtils.mkdir_p("script_span")

the_prefix = File.expand_path(File.dirname(__FILE__))

[ "feature_extractor", "sentence", "task_spec" ].each {|name|
  Dir.chdir("#{the_prefix}/ext/src") do
    cmd = "protoc '#{name}.proto' --cpp_out='.'"
    puts cmd
    `#{cmd}`
    ln_fallback("#{name}.pb.h", "#{the_prefix}/cld_3/protos/#{name}.pb.h")
  end
}

[
  "fixunicodevalue.h",
  "generated_ulscript.h",
  "getonescriptspan.h",
  "integral_types.h",
  "offsetmap.h",
  "port.h",
  "stringpiece.h",
  "text_processing.h",
  "utf8acceptinterchange.h",
  "utf8prop_lettermarkscriptnum.h",
  "utf8repl_lettermarklower.h",
  "utf8scannot_lettermarkspecial.h",
  "utf8statetable.h"
].each {|name|
  ln_fallback("#{the_prefix}/ext/src/script_span/#{name}", "#{the_prefix}/script_span/#{name}")
}

$CXXFLAGS += " -fvisibility=hidden -std=c++11 -I#{the_prefix}/ext/src"
create_makefile("libcld3")

=begin
Command:
./watchexec --on-busy-update=do-nothing -f '*untitled*' -f '*.srt' -f '*.zip'\
    -w ~/Downloads/ ruby ~/gitbase/osx_utils/subhelper.rb
=end

require 'logger'
require 'securerandom'
require 'fileutils'

# sleep(3)

LOGGER = Logger.new(STDOUT)
created_path = ENV["WATCHEXEC_CREATED_PATH"]
common_path = ENV["WATCHEXEC_COMMON_PATH"] 
target_locale = ENV["LANGUAGE"]
RUN_ID = "#{SecureRandom.hex(9)}_subhelper"
# We perform all operations and store 
# intermediate files in each run's own tmp_dir
TMP_DIR = File.join(__dir__, "temp", RUN_ID) 
@is_existing_srt = false

TWO_HUNDRED_MB = 200*1000*1000
target_vid = nil # Target video file
vid_suffix = nil

FileUtils.mkdir_p(TMP_DIR)
LOGGER.info("===========================")
LOGGER.info("           BEGIN           ")
LOGGER.info(" Target Language: #{target_locale} ")

def do_exit()
    LOGGER.info("------- No action. -------")
    LOGGER.info("--------------------------")
    exit(0)
end

def find_and_extract_srt_file(dir)
    # Recursively find the srt file. If multiple are found, try the one with
    # the target locale in it (ENV["LANGUAGE"])
    LOGGER.info("Searching for srt within #{dir}/")
    srt_files = IO.popen("find '#{dir}' -name '*.srt'").map {|f| f.chomp }
    identified_srt = nil

    if (srt_files.size == 1)
        identified_srt = srt_files.first
    elsif (srt_files.size > 1)
        identified_srts = srt_files.select do |f|
            f.downcase.include?(target_locale)
        end

        if(identified_srts.size > 1)
            LOGGER.info("Multiple target srt files found! unable to find the correct one")
            do_exit()
        else
            identified_srt = identified_srts.first
        end

        unless(identified_srt)
            LOGGER.info("Multiple srt candidates found!")
            LOGGER.info("Here they are:")
            srt_files.each do |srtfile|
                LOGGER.info(srtfile)
            end
            do_exit()
        end
    else
        LOGGER.info("Could not find an srt file.")
        do_exit()
    end

    if(@is_existing_srt)
        LOGGER.info("✔ Using existing srt file")    
    else
        LOGGER.info("✔ Using srt file: #{identified_srt}")
    end
    system("mv '#{identified_srt}' '#{TMP_DIR}/#{RUN_ID}.srt'")
end

def handle_zip(zip_path, base_dir_path)
    zip_dest = TMP_DIR
    system("unzip '#{zip_path}' -d '#{zip_dest}'")

    find_and_extract_srt_file(zip_dest)
end

unless(common_path && created_path)
    do_exit()
end

item_path = File.join(common_path, created_path)
base_dir = File.dirname(item_path)

# If multiple files are added or deleted at the same time
# created_path will have multiple values separated by :
# example: sub1.srt:sub2.srt:eng/sub01.srt.
# We do not want to deal with this case
if(item_path.include?(":"))
    do_exit()
end

item_ext = File.extname(item_path)

# When creating an "untitled folder" we basically are finding
# an existing srt file, and then simulating the case where a 
# new srt file got added by the user, thereby triggering
# the normal `srt file addition` flow.
@is_existing_srt = item_path.end_with?("untitled folder/")

if(@is_existing_srt)
    find_and_extract_srt_file(base_dir)
    
    tmp_srt_file = File.join(base_dir, "tmp_subhelper_target_file.srt")
    system("mv '#{TMP_DIR}/#{RUN_ID}.srt' '#{tmp_srt_file}'")

    item_path = tmp_srt_file
    item_ext = ".srt"
end

item_name = File.basename(item_path)

unless([".zip", ".srt"].include?(item_ext))
    LOGGER.info("Item #{item_path} ignored.")
    do_exit();
end

LOGGER.info("finding video in #{base_dir}/")
IO.popen("find '#{base_dir}' -name '*mp4' -o -name '*mkv'").each do |file|
    vid = file.chomp

    if(File.size(vid) > TWO_HUNDRED_MB)
        target_vid = vid
        vid_suffix = File.basename(target_vid, ".*")
    end
end

unless (target_vid && vid_suffix)
    LOGGER.info("Could not find/identify target video content.")
    do_exit()
else
    LOGGER.info("Video found ✔✔✔")
end

if (item_ext == ".zip")
    LOGGER.info("Processing new zip file [#{item_name}] ..")
    handle_zip(item_path, base_dir)
elsif (item_ext === ".srt")
    srt_file_descriptor = @is_existing_srt ? "existing srt file" : "srt file [#{item_name}] .."
    LOGGER.info("Processing #{srt_file_descriptor}")
    find_and_extract_srt_file(base_dir)
end

# At this point the identified_srt should be ready
# in the TMP_DIR.

target_srt_file = File.join("#{TMP_DIR}", "#{RUN_ID}.srt")
system("mv '#{target_srt_file}' '#{base_dir}/#{vid_suffix}.srt'")









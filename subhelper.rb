=begin
Command (watchexec v2+):
watchexec --on-busy-update=do-nothing \
    --emit-events-to=environment \
    -w ~/Downloads/ \
    ruby ~/gitbase/devvm/subhelper_for_mac/subhelper.rb

Note: no -F filters here — watchexec silently drops directory-creation events
(like "untitled folder") when path filters are active. The Ruby script handles
all filtering internally.
=end

require 'logger'
require 'securerandom'
require 'fileutils'

LOGGER = Logger.new(STDOUT)


# Catch all event types: create, write, rename/move, and anything else watchexec fires
created_path = ENV["WATCHEXEC_CREATED_PATH"] ||
               ENV["WATCHEXEC_WRITTEN_PATH"]  ||
               ENV["WATCHEXEC_RENAMED_PATH"]  ||
               ENV["WATCHEXEC_OTHERWISE_CHANGED_PATH"]
common_path = ENV["WATCHEXEC_COMMON_PATH"]
TARGET_LOCALE = ENV["LANGUAGE"]
RUN_ID = "#{SecureRandom.hex(9)}_subhelper"
TMP_DIR = File.join(__dir__, "temp", RUN_ID)
@is_existing_file = false

TWO_HUNDRED_MB = 200 * 1000 * 1000
target_vid = nil
vid_suffix = nil

FileUtils.mkdir_p(TMP_DIR)
LOGGER.info("===========================")
LOGGER.info("           BEGIN           ")

def do_exit
    LOGGER.info("------- No action. -------")
    LOGGER.info("--------------------------")
    exit(0)
end

def recursively_unzip_zips(dir)
    zip_files = IO.popen("find '#{dir}' -name '*.zip'").map(&:chomp)
    zip_files.each do |z|
        system("unzip -u '#{z}' -d '#{File.dirname(z)}'")
    end
end

def find_and_extract_srt_file(dir)
    unless @is_existing_file
        LOGGER.info("Searching for srt within #{dir}/")
    end

    srt_files = IO.popen("find '#{dir}' -name '*.srt'").map(&:chomp)
    identified_srt = nil

    if srt_files.size == 1
        identified_srt = srt_files.first
    elsif srt_files.size > 1
        identified_srts = srt_files.select do |f|
            "#{File.dirname(f)}/#{File.basename(f)}".downcase.include?(TARGET_LOCALE)
        end

        if identified_srts.size > 1
            LOGGER.warn("---> Error: Multiple target srt files found! unable to know the correct one")
            do_exit
        else
            identified_srt = identified_srts.first
        end

        unless identified_srt
            LOGGER.warn("---> Error: Multiple srt candidates found:")
            LOGGER.info("Subhelper would not know the correct one to use.")
            LOGGER.info("Here they are:")
            srt_files.each { |f| LOGGER.info(f) }
            do_exit
        end
    else
        LOGGER.info("Could not find an srt file.")
        do_exit
    end

    unless @is_existing_file
        LOGGER.info("✔ Using srt file: #{identified_srt}")
    end
    system("mv '#{identified_srt}' '#{TMP_DIR}/#{RUN_ID}.srt'")
end

def handle_zip(zip_path, base_dir_path)
    system("unzip '#{zip_path}' -d '#{TMP_DIR}'")
    find_and_extract_srt_file(TMP_DIR)
end

do_exit unless created_path

# If multiple files triggered at once, watchexec separates them with : or \n
# We'll take the last one, which is usually the final path after a download/rename.
if created_path.include?(":")
    created_path = created_path.split(':').last
end

# In watchexec v2, paths may already be absolute; in v1 they're relative to common_path
item_path = if created_path.start_with?('/')
    created_path
elsif common_path
    File.join(common_path, created_path)
else
    do_exit
end

# Ignore temp download files from browsers
if item_path.end_with?('.crdownload', '.download')
    do_exit
end

item_path = item_path.strip
base_dir = File.dirname(item_path)
item_ext = File.extname(item_path)

# Creating an "untitled folder" is a manual trigger to find an existing srt and
# run the normal srt-addition flow. Works regardless of trailing slash from watchexec.
@is_existing_file = File.basename(item_path.chomp('/')) == "untitled folder"

if @is_existing_file
    recursively_unzip_zips(base_dir)
    find_and_extract_srt_file(base_dir)

    tmp_srt_file = File.join(base_dir, "tmp_subhelper_target_file_#{TARGET_LOCALE}.srt")
    system("mv '#{TMP_DIR}/#{RUN_ID}.srt' '#{tmp_srt_file}'")

    FileUtils.rm_rf(item_path)
    item_path = tmp_srt_file
    item_ext = ".srt"
else
    item_name = File.basename(item_path)
    unless [".zip", ".srt"].include?(item_ext)
        LOGGER.info("Item #{item_path} ignored.") unless item_name == "untitled folder"
        do_exit
    end
end

LOGGER.info("finding video in #{base_dir}/")
IO.popen("find '#{base_dir}' -name '*mp4' -o -name '*mkv'").each do |file|
    vid = file.chomp
    if File.size(vid) > TWO_HUNDRED_MB
        target_vid = vid
        vid_suffix = File.basename(target_vid, ".*")
    end
end

unless target_vid && vid_suffix
    LOGGER.info("Could not find/identify target video content.")
    do_exit
end

LOGGER.info("Video found ✔✔✔")

if item_ext == ".zip"
    LOGGER.info("Processing new zip file [#{item_name}] ..")
    handle_zip(item_path, base_dir)
elsif item_ext == ".srt"
    # If the srt file is already named correctly, we're done.
    if item_name == "#{vid_suffix}.srt"
        LOGGER.info("Subtitle file '#{item_name}' is already correctly named.")
        do_exit
    end

    srt_file_descriptor = @is_existing_file ? "existing srt file" : "srt file [#{item_name}] .."
    LOGGER.info("Processing #{srt_file_descriptor}")
    find_and_extract_srt_file(base_dir)
end

# At this point the identified_srt should be ready in the TMP_DIR.
target_srt_file = File.join(TMP_DIR, "#{RUN_ID}.srt")
system("mv '#{target_srt_file}' '#{base_dir}/#{vid_suffix}.srt'")

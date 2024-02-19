## Subhelper for Mac

### What is Subhelper?
Subhelper is a small program for Mac OS that will automatically find and rename subtitle files (.srt) to match with the video content (movies/documentaries/episodes, etc.) within a given directory.


### Install and running subhelper
- Just download or clone the repository.
- `sh start.sh` will start subhelper and prompt for necessary inputs that it requires.
- Once started, it keeps running in a `continuous` scan mode for a specified `parent directory`


### What can subhelper do?
For example, if I store all my movies in /Users/sasanka/Downloads/movies/

I can run Subhelper with the parent path set to
`/Users/sasanka/Downloads/movies/`
And my `preferred language` set to `eng` (first 3 letters of `english`). This is used when multitple `srt` files are found and `subhelper` needs to `decide which one to pick`.

Let's look at the following use-cases:

1. I have two movies in the directory such as below: 
  - `/Users/sasanka/Downloads/movies/King Kong 2005 DvdRip/`
    - `King Kong 2005 DvdRip_Original.mp4`
- `/Users/sasanka/Downloads/movies/Interstellar 2014 BluRay/`
  - `Interstellar_2014_Bluray.mp4`

  I start `subhelper` with `sh start.sh` and enter the parent directory as `/Users/sasanka/Downloads/movies/`;
  1. Then, I either download or paste a subtitle file called
  `king_kong_sub.srt` into the `King Kong 2005 DvdRip/` directory above. `subhelper` will detect this new file and automatically rename it to `King Kong 2005 DvdRip_Original.srt` to match the corresponding `mp4` file.
  2. Next, I download a `zip` file from the internet containing the subtitles for `Interstellar`, called `interstellar_2014_subs.zip`, into the `Interstellar 2014 Bluray/` folder above. `subhelper` will automatically `unzip` the zip, and then rename the extracted `.srt` file from the extracted content to `Interstellar_2014_Bluray.srt`


2. The second use-case is where there are already `subtitles` present in the corresponding directories, but not with correct file names, such as below:

- `/Users/sasanka/Downloads/old_movies/Memento 2000 bluRay/`
  - `Memento_2000_Bluray.mp4`
  - `Eng_subs.srt`

- `/Users/sasanka/Downloads/old_movies/The Terminator 1984 1080p/`
  - `Terminator_1984_DvdRip_1080.mp4`
  - `subtitles/`
    - `english/`
      - `Terminator_1984_subs.zip`

- `/Users/sasanka/Downloads/old_movies/citizen_kane_1941/`
  - `citizen_kane_1941.mp4`
  - `subs/`
    - `free/`
      - `english.srt`

  As you can see above, there are already subtitles present, either in the form of `.srt` file, or within a compressed `zip` file. 
  In this case, I will start `subhelper` with `start.sh` and set the parent directory to `/Users/sasanka/Downloads/old_movies/`;  
  Now, note that `subhelper` will not automatically perform irreversible operations without user consent, so I will `prompt` subhelper by `creating a new folder within the directory I'm interested in`, with a simple keyboard shortcut, which is `Cmd+Shift+N` and `not really do anything else`. This will "trigger" `subhelper` to scan within the directory I created the `untitled folder` in, and perform its duties, which are:
  - automatically rename the `Eng_subs.srt` to `Memento_2000_Bluray.srt`
  - automatically scan all subdirectories within the `The Terminator 1984 1080p/` directory, find the `Terminator_1984_subs.zip`, extract it, find an `.srt` file within the extracted content, and rename it to `Terminator_1984_DvdRip_1080.srt`, and put it alongside the corresponding `Terminator_1984_DvdRip_1080.mp4` file.
  - automatically scan all subdirectories within the `citizen_kane_1941` directory, find the `english.srt` file, rename it to `citizen_kane_1941.srt` and put it alongside the `citizen_kane_1941.mp4` file.


  Again, the `creation of untitled folder` is just a way to trigger `subhelper` when you know there are existing subtitles within a folder. I hope it is still acceptable since it only needs a quick keyboard combination of `Cmd+shift+N`. Note that `subhelper` will automatically delete this `untitled folder` after running its operations, so please do not get confused over it!

### What Subhelper cannot do
Suhelper cannot find or download `subtitle` files or any other content from the internet. It is just a tool for `organizing` subtitle files/content automatically. For subtitle content, it is up to you, the user, to find and download subtitle content from whatever sources that you may use (typically a website like https://opensubtitles.org for example).


### Contributions
I do not have the time or bandwidth to accept Pull Requests right now, but please feel free to fork the repo and make changes in whatever ways you prefer.

### Thank you, and hope you found this little tool helpful.

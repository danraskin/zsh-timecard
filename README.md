# Zsh Timetracker

A simple command-line utility for tracking time spent on different projects. It provides basic reporting capabilities.

## Installation

```bash
git clone https://github.com/danraskin/zsh-timetracker.git

# navigate to file directory
cd ~/path/timetracker/

# make timetracker executable
chmod +x timetracker.zsh

# to run timetracker from any file location,
# create symlink in a PATH directory using absolute filepath to timetracker.zsh from ROOT
ln -s /root/path/to/timetracker/timetracker.zsh /usr/local/bin/timetracker

```

## Usage: timetracker [OPTIONS]

- **[-p PROJECT]**  Start tracking a project
- **[-t TASK]**     Start tracking a task (must be used with -p)
- **[-pt PROJECT]** Start tracking a project and task
- **[start]**       Start tracking time for the current project/task
- **[stop]**        Stop tracking time for the current project/task
- **[print]**       Print work history
- **[help, -h]**    Show this help message

## Notes

I've been attempting to keep track of my time spent on various projects using Google Sheet. This met my needs, but I got curious: could I write a script to do this for me? I took this as an opportunity to try two new things: Learning shell scripting and gaining experience using ChatGPT and other AI tools as learning/productivity tools. The first iterations of the script were the outputs of ChatGPT prompts. Subsequent iterations were developed using further ChatGPT prompts, [Zsh documentation](https://zsh.sourceforge.io/Doc/Release/) and other online resources. More reflections on this process can be read [here](https://danraskin-portfolio.vercel.app/blog)

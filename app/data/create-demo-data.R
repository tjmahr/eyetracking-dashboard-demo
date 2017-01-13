# I can't put the actual datasets we use in the dashboard in a public demo, but
I # will use some older data as an example.

library(dplyr, warn.conflicts = FALSE)

raw_looks <- readr::read_csv("https://raw.githubusercontent.com/tjmahr/2015_Coartic/master/data/gazes.csv")
raw_trials <- readr::read_csv("https://raw.githubusercontent.com/tjmahr/2015_Coartic/master/data/trials.csv")
raw_subj <- readr::read_csv("https://raw.githubusercontent.com/tjmahr/2015_Coartic/master/data/subj.csv")

trials <- raw_trials %>%
  rename(Condition = StimType, Subject = Subj) %>%
  # Renumber trials within child:block, instead of within child
  mutate(TrialID = paste(Subject, Block, TrialNo, sep = "-")) %>%
  group_by(Subject, Block) %>%
  mutate(TrialNo = seq_along(sort(TrialNo))) %>%
  ungroup()

trial_nums <- trials %>% select(TrialID, TrialNo)

looks <- raw_looks %>%
  rename(Subject = Subj) %>%
  # Also renumber trials here
  mutate(TrialID = paste(Subject, Block, TrialNo, sep = "-")) %>%
  select(-TrialNo) %>%
  left_join(trial_nums)

trials <- trials %>% select(-TrialID)
looks <- looks %>% select(-TrialID)

# Create arbitrary groups based Even/Odd subject number
subj <- raw_subj %>%
  mutate(StudySet = "Dashboard Demo",
         Group = ifelse(as.numeric(Subj) %% 2 == 0, "Even", "Odd")) %>%
  rename(Subject = Subj) %>%
  select(StudySet, Group, Subject, Age, CDI)

# Long format so that we can use child-level measures to plot looks
subj <- subj %>%
  tidyr::gather(Measure, Value, -Subject, -Group, -StudySet)

looks <- looks %>%
  left_join(trials) %>%
  left_join(subj) %>%
  select(StudySet, Experiment, Group, Block, Subject, Condition, TrialNo,
         ImageL, ImageR, TargetImage, Time, GazeByImageAOI)

save(looks, file = "./app/data/data.rds")
readr::write_csv(subj, "./app/data/scores.csv")


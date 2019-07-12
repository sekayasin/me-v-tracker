# VOF Changelog

## 10th November, 2017

### Added

- Learners can view a profile page populated with their biodata and activities
  - Learners can edit their profiles
- Learners have access to a learning ecosystem page which shows the outputs required for their current program
  - Learners can submit and edit links to required outputs
  - They can view how many outputs they have submitted and their percentage completion
- Users have access to a support page with FAQs and contact information (tailored to whether you are a learner or an Andelan)
- Support for multiple programs (not just Bootcamp)
  - When uploading learners, an admin can choose which program they are participating in
  - An admin can create a new program with its own phases
    - Likewise, they can edit existing programs
    - When creating a program, they can save a draft and return to it later
    - Admins can finalize a draft (Finalized programs are indicated with an closed padlock, while programs in draft mode are indicated with an open padlock). Non-admins only see finalized programs.
    - The draft overview page is populated with changes made to the draft program
    - Admins can also clone an existing program
  - The dashboard can be filtered by program as well location, cycle, etc
- Andelans can overview a program including its duration, stack, etc as well as view more details about it (such as the assessments it requires)
- LFAs and learners can use the platform to give and receive ASK feedback (respectively)
  - Learners can submit reflection based on the feedback given
- Andelans can sort the curricula tables (framework, criteria and outputs) in ascending or descending order
- The AIS UUIDs of accepted learners have been added to the database/exported CSV

### Changed

- Learners are now assessed based on the Dev Framework attributes (Quantity, Quality, Initiative, Professionalism, Communication, Integration)
- The scoring page now has the learner's profile information
- The scoring page has a link to view the link submitted for an output
- The cycle dropdown on the dashboard is now sorted in descending order
- Learners are now scored using a qualitative rating
- Admins can edit the description of a framework (Values Alignment, Output Quality or Feedback)
- The dashboard can now be filtered by multiple terms (e.g. more than one cycle or LFA)
- The program overview page can now be sorted based on its name or estimated length in ascending/descending order
- The add learners page now has a scroll bar for displaying more than 5 previously uploaded learner cycles

### Fixed

- Search results (for users) now persist even with saved filters
- Progress percentages are now represented as whole numbers
- Extra whitespaces in a spreadsheet of learners no longer prevent the file from being uploaded
- Every part of the application's action buttons is now clickable (before, the edges did not register clicks)
- Generating and downloading a CSV which previously took hours now takes seconds to complete
- The table headers for the sections in the content management page no longer disappear on refresh

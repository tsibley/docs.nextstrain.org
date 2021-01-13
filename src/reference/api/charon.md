# Charon API

## Unversioned API
A dynamic server, also unofficially called "v1".
Previously [documented here](https://docs.nextstrain.org/projects/auspice/en/latest/server/api.html).


## V2
Version 2 (v2) of the charon API will be static instead of dynamic.
Some of the content on this page comes from the linked discussions and notes below:
* Tom's notes from [Dec 26, 2018](https://github.com/tsibley/blab-standup/blob/master/2018-12-26.md#proposed)
* GitHub discussion on [Jan 1, 2019](https://github.com/nextstrain/auspice/issues/687)
* Tom's notes from [Apr 9, 2020](https://github.com/tsibley/blab-standup/blob/master/2020-04-09.md)


### Motivation
Creating an API in REST format will better enable us to extend the customers of the API which is especially important with respect to how we want to use Nextstrain Groups for outreach and to enable data accessibility.
For example, we could perform dataset operations via the Nextstrain CLI (see [relevant issue](https://github.com/nextstrain/cli/issues/90)).
We could eventually build a custom UI for Nextstrain.org to allow dataset management within the browser.


### Proposed design
This new design will maintain complete, backwards compatibility with the unversioned charon API.

action  | method  | v1 (`/charon`)    | v2 (`/charon/v2`)   | notes
---     | ---     | ---               | ---                 | ---
list all datasets at top-level | GET | `/getAvailable` | `/dataset` | v1 also lists narratives
list all datasets at path | GET | `/getAvailable?prefix={datasetPath}` | `/dataset/{datasetPath}` | see note above
retrieve dataset at path | GET | `/getDataset?prefix={datasetPath}` | `/dataset/{datasetPath}.json` |
retrieve dataset at path | GET | `/getDataset?prefix={datasetPath}&type={type}` | `/dataset/{datasetPath}/{type}.json` |
list all narratives at top-level | GET | not implemented | `/narrative`   | for v1, `/getAvailable` returns all narratives
list all narratives at path | GET | not implemented | `/narrative/{narrativePath}` | see note above
retrieve narrative at path | GET | `/getNarrative?prefix={narrativePath}&type=md` | `/narrative/{narrativePath}.md` | `.markdown` extension will also be accepted.
retrieve source info at path | GET | `/getSourceInfo?prefix={datasetPath}` | TBD |
upload dataset(s) at path | PUT | not implemented | `/dataset/{datasetPath}` | must be specific to dataset
upload narrative(s) at path | PUT | not implemented | `/narrative/{narrativePath}` | must be specific to dataset
remove dataset(s) at path | DELETE | not implemented | `dataset/{datasetPath}` | must be specific to dataset
remove narrative(s) at path | DELETE | not implemented | `narrative/{narrativePath}` | must be specific to narrative


#### TODO
How to implement:
* redirects (e.g. `/charon/v2/dataset/flu` → `/charon/v2/dataset/flu/seasonal/h3n2/ha/2y`)
* support old JSON formats (v1, meta+tree)
* 204 responses (which are possible from `/charon/getDataset` and are relied on by auspice)
* is our synatx for getting a dataset `/charon/v2/dataset/{datasetPath}/main.json` or is it `/charon/v2/dataset/{datasetPath}.json`?


#### New Features
Some ideas for new features not covered in the table above include:

* ability to filter datasets or narratives (e.g. based on maintainer name)


#### Examples
Complete examples of v2 API requests and their expected response codes will live in the [Nextstrain.org smoke-tests](https://github.com/nextstrain/nextstrain.org/blob/master/test/smoke-test/auspice_client_requests.test.js).
Some v2 examples are also written in the section here on [Proposed CLI Syntax](#proposed-cli-syntax).

description | v1 request    | v2 request
---         | ---           | ---
list all datasets and narratives in community dataset | `/charon/getAvailable?prefix=/community/blab/zika-colombia` | [`/charon/v2/dataset/community/blab/zika-colombia`, `/charon/v2/narrative/community/blab/zika-colombia`] |
retrieve core dataset | `/charon/getDataset?prefix=/flu/seasonal/h3n2/ha/2y` | `/charon/v2/dataset/flu/seasonal/h3n2/ha/2y`
retrieve core narrative | `/charon/getNarrative?prefix=/narratives/ncov/sit-rep/2020-05-15&type=md` | `/charon/v2/narrative/ncov/sit-rep/2020-05-15.md`


### Proposed CLI Syntax
The Nextstrain CLI will be a prominent client of the v2 API.
Considering the desired UX of the CLI can help inform how v2 should be designed.
The following CLI examples are adapted from [Tom's notes](https://github.com/tsibley/blab-standup/blob/master/2020-04-09.md).

`nextstrain remote ls nextstrain.org`

    → GET nextstrain.org/charon/v2/dataset

`nextstrain remote ls nextstrain.org/groups/blab`

    → GET nextstrain.org/charon/v2/groups/blab

`nextstrain remote download nextstrain.org/flu/seasonal/h3n2/ha/2y`

    → GET nextstrain.org/charon/v2/dataset/flu/seasonal/h3n2/ha/2y/main.json
    → GET nextstrain.org/charon/v2/dataset/flu/seasonal/h3n2/ha/2y/tip-frequencies.json
    → GET nextstrain.org/charon/v2/dataset/flu/seasonal/h3n2/ha/2y/….json

`nextstrain remote download nextstrain.org/flu`

    → fails; not specific to a dataset; could be supported in future

`nextstrain remote upload nextstrain.org/ncov/ global.json europe.json …`

    → PUT nextstrain.org/charon/v2/dataset/ncov/global.json
    → PUT nextstrain.org/charon/v2/dataset/ncov/europe.json
    …

`nextstrain remote rm nextstrain.org/flu/seasonal/h3n2/ha/2y`

    → DELETE nextstrain.org/charon/v2/dataset/flu/seasonal/h3n2/ha/2y/main.json
    → DELETE nextstrain.org/charon/v2/dataset/flu/seasonal/h3n2/ha/2y/tip-frequencies.json
    → DELETE nextstrain.org/charon/v2/dataset/flu/seasonal/h3n2/ha/2y/….json

`nextstrain remote rm nextstrain.org/flu`

    → fails; not specific to a dataset; matches existing behaviour

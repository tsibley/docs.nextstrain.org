=======================================
Scalable Sharing with Nextstrain Groups
=======================================

We want to enable research labs, public health entities and others to share their datasets and narratives through Nextstrain with complete control of their data and audience. Nextstrain Groups is more scalable than :doc:`community builds </guides/share/community-builds>` in both data storage and viewing permissions.
Each group manages its own AWS S3 Bucket to store datasets and narratives, allowing many large datasets. Data of a public group are accessible to the general public via nextstrain.org, while private group data are only visible to logged in users with permissions to see the data. A single entity can manage both a public and a private group in order to share data with different audiences.

.. note::

   Nextstrain Groups is still in the early stages and require a Nextstrain team member to set up and add users.
   Please `get in touch with us <mailto:hello@nextstrain.org>`_ and we'd be happy to set up a group for you.

.. contents:: Table of Contents
   :local:
   :depth: 1

How does it work?
=================

  1. Run your analysis locally (:doc:`see the bioinformatics introduction <augur:index>`)
  2. Upload the datasets or narratives you've produced to the group's AWS S3 Bucket

     * There are no naming restrictions of the dataset JSONs (see :doc:`expected formats </reference/formats/data-formats>`)
     * Narrative Markdown files cannot be named ``group-overview.md`` but otherwise there are no naming restrictions

  3. Access your data via the group's splash page at "nextstrain.org/groups/" + "group name". Example: `nextstrain.org/groups/blab <https://nextstrain.org/groups/blab>`_.

Configure your AWS credentials
==============================

Before you can upload data to your Nextstrain Group, you need to define your AWS credentials, so the Nextstrain CLI knows how to access your AWS resources.

Create a new directory to store your AWS credentials and other configuration details.

.. code-block:: bash

   # Creates a new hidden directory in your home directory
   # and does not throw an error if the directory already exists.
   mkdir -p ~/.aws

Next, create a new file to store your AWS credentials.

.. code-block:: bash

   nano ~/.aws/credentials

Define your credentials in this file like so, replacing the “…” values with the corresponding key id and secret access key provided to you by the Nextstrain team. In the same file, we also define the default AWS region for your Nextstrain Groups data.

.. code-block:: ini

   [default]
   aws_access_key_id=...
   aws_secret_access_key=...
   region=us-east-1

Save this file and return to the command line.

Confirm that you have access to your Nextstrain Groups AWS resources, by listing the contents of your group’s S3 bucket. Replace ``<group>`` below with your group name.

.. code-block:: bash

   nextstrain remote list s3://nextstrain-<group>

This command should list all the files in your bucket. Your bucket will likely be empty by default.

Customize your group's page
===========================

You can customize the content of your group's page by uploading two files to the group's S3 bucket:

* ``group-logo.png``: logo to display at the top of the page
* ``group-overview.md``: a description of your group and the Nextstrain builds your group provides

Create a new file named ``group-overview.md`` that will contain information about your group.
At the top of this file, provide a title for the page, a list of people who maintain the data, a website, and whether to show datasets or narratives from your group.
This information is technically known as the `YAML front matter <https://jekyllrb.com/docs/front-matter/>`_ for the file.
You must provide a ``title`` and define ``showDatasets`` and ``showNarratives`` as either ``true`` or ``false``.
The ``byline`` and ``website`` are optional.

.. code-block:: yaml

   ---
   title: "Your Department of Health and Human Services"
   byline: "Your Name Here"
   website: https://
   showDatasets: true
   showNarratives: true
   ---

   A description of your organization goes here.

After the front matter (in the lines following the last ``---`` characters), write a description of your organization to provide context for users who can access your groups page.
Use `Markdown syntax <https://www.markdownguide.org/basic-syntax/>`_ to format the contents of your group description with headers, lists, links, etc.
This content will appear between the byline and the list of available datasets on the group's page.

Upload your logo and description to your group’s S3 bucket.

.. code-block:: bash

   nextstrain remote upload s3://nextstrain-<group>/ \
     group-logo.png group-overview.md

To update your logo, description, or any other data in your group’s S3 bucket, run the ``nextstrain remote upload`` command again and the uploaded data will replace the previous contents in the bucket.

Upload a Nextstrain build
=========================

.. warning::

   Do not upload personally identifiable information (PII) as part of your build data.
   This restriction applies for public and private groups.

Next, upload one or more Nextstrain builds for your group.

.. code-block:: bash

   nextstrain remote upload s3://nextstrain-<group>/ \
     auspice/ncov_<your-build-name>.json \
     auspice/ncov_<your-build-name>_tip-frequencies.json \
     auspice/ncov_<your-build-name>_root-sequence.json

After the upload completes, navigate to your groups page from `https://nextstrain.org/groups/ <https://nextstrain.org/groups/>`_ to see the build you uploaded.
Alternately, upload multiple build files at once with wildcard syntax.

.. code-block:: bash

   nextstrain remote upload s3://nextstrain-<group>/ auspice/*.json

Remove files from your group
============================

You can remove specific files from your group's S3 bucket using the ``nextstrain remote delete`` command.
For example, the following command removes your group logo and overview files.

.. code-block:: bash

   nextstrain remote delete \
     s3://nextstrain-<group>/group-logo.png \
     s3://nextstrain-<group>/group-overview.md

You can use a similar command to remove multiple files with the same prefix.
For example, the following command removes all files associated with a specific build's prefix.

.. code-block:: bash

   nextstrain remote delete \
     --recursively \
     s3://nextstrain-<group>/ncov_<your-build-name>

Learn more about the Nextstrain command line interface
======================================================

:doc:`See the Nextstrain CLI's documentation <cli:commands/remote/index>`, to learn more about how to work with your group’s S3 bucket.
You can also learn more by viewing the help for this command.

.. code-block:: bash

   nextstrain remote -h

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

module.exports = async ({ github, context }) => {
  const owner = context.repo.owner;
  const repo = context.repo.repo;
  const labelName = 'waiting for response';
  const daysUntilClose = 21;

  const prCloseComment = `This pull request is being closed because it has not been updated in the last 21 days after a request for more information.

If you are still working on this, please feel free to reopen it or file a new pull request.

Thanks for your contribution.`;

  const now = new Date();
  const closeDate = new Date(now.getTime() - (daysUntilClose * 24 * 60 * 60 * 1000));

  // GitHub's pulls REST API does not support filtering by label. In GitHub's
  // data model, pull requests are treated as issues, so we query the issues
  // endpoint with the target label. Since issues are disabled in flutter/packages,
  // this will only return pull requests.
  const prs = await github.paginate(github.rest.issues.listForRepo, {
    owner,
    repo,
    state: 'open',
    labels: labelName,
  });

  for (const pr of prs) {
    if (!pr.pull_request) {
      continue;
    }

    // Fetch timeline events to find label date
    const events = await github.paginate(github.rest.issues.listEvents, {
      owner,
      repo,
      issue_number: pr.number,
    });

    const labelEvent = events.reverse().find(
      event =>
        event.event === 'labeled' &&
        event.label.name === labelName
    );

    if (!labelEvent) {
      continue; // Skip if label not found in events
    }

    const labeledAt = new Date(labelEvent.created_at);
    let isResponse = false;

    // Check for author comments after label
    const comments = await github.paginate(github.rest.issues.listComments, {
      owner,
      repo,
      issue_number: pr.number,
      since: labeledAt.toISOString(),
    });

    for (const comment of comments) {
      if (comment.user?.id === pr.user?.id && new Date(comment.created_at) > labeledAt) {
        isResponse = true;
        break;
      }
    }

    // Check for commits after label
    if (!isResponse) {
      const commits = await github.paginate(github.rest.pulls.listCommits, {
        owner,
        repo,
        pull_number: pr.number,
      });

      for (const commit of commits) {
        const commitDate = new Date(commit.commit.committer?.date || commit.commit.author?.date);
        if (commitDate > labeledAt) {
          isResponse = true;
          break;
        }
      }
    }

    if (isResponse) {
      console.log(`Removing label from #${pr.number} as author responded.`);
      await github.rest.issues.removeLabel({
        owner,
        repo,
        issue_number: pr.number,
        name: labelName,
      });

      continue; // Skip stale check
    }

    // Stale check
    if (pr.state === 'open') {
      if (labeledAt < closeDate) {
        if (pr.locked) {
          console.log(`Skipping #${pr.number} because the conversation is locked.`);
          continue;
        }

        console.log(`Closing #${pr.number} due to no response.`);
        await github.rest.issues.createComment({
          owner,
          repo,
          issue_number: pr.number,
          body: prCloseComment,
        });
        await github.rest.issues.update({
          owner,
          repo,
          issue_number: pr.number,
          state: 'closed',
        });
      }
    }
  }
};

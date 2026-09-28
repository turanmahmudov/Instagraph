WorkerScript.onMessage = (message) => {
  const items = message.items;
  const friend_requests = message.friend_requests;
  const partition = message.partition;
  const model = message.model;

  if (message.clear) {
    model.clear();
  }

  if (friend_requests) {
    let item_obj = {};
    item_obj.list_type = "follow_requests";

    item_obj.request_count = friend_requests[0].args.request_count;
    item_obj.profile_pic_url = friend_requests[0].args.profile_image;

    model.append(item_obj);
    model.sync();
  }

  items.forEach((item, i) => {
    let item_obj = {};

    item_obj.list_type = "recent_activity";

    item_obj.header = generateHeader(partition, i) || "";
    item_obj.activity_text = generateActivityText(item.args, message.linkColor);

    item_obj.story_type = item.type;
    item_obj.profile_image =
      "profile_image" in item.args ? item.args.profile_image : "";
    item_obj.profile_id =
      "profile_id" in item.args ? item.args.profile_id : "";
    item_obj.media =
      "media" in item.args && item.args.media.length > 0
        ? item.args.media[0]
        : { image: "", id: "" };
    if ("inline_follow" in item.args) {
      item_obj.inline_follow = item.args.inline_follow;
    }
    item_obj.timestamp = item.args.timestamp || 0;

    model.append(item_obj);
    model.sync();
  });
};

function generateActivityText(args, linkColor) {
  if (!args) return "";

  if (!("links" in args)) {
    if ("rich_text" in args) return args.rich_text;
    return args.text;
  }

  if (args.links.length === 0) return "";

  // links
  let activity_text = args.text;
  let linked_part = [];
  let linked_part_types = [];
  let linked_part_ids = [];

  args.links.forEach((link, i) => {
    linked_part[i] = activity_text.substring(link.start, link.end);
    linked_part_types[i] = link.type;
    linked_part_ids[i] = link.id;
  });

  linked_part.forEach((part, j) => {
    let replace_with;
    if (linked_part_types[j] === "like_count_chrono") {
      replace_with = makeLink(`likes://${part}`, part, linkColor);
      activity_text = activity_text.replace(part, replace_with);
    } else if (linked_part_types[j] === "user") {
      replace_with = makeLink(
        `userid://${linked_part_ids[j]}`,
        part,
        linkColor,
      );
      activity_text = activity_text.replace(part, replace_with);
    }
  });

  return activity_text;
}

function generateHeader(partition, index) {
  if (!partition) return "";
  if (!("time_bucket" in partition)) return "";

  for (let j = 0; j < partition.time_bucket.headers.length; j++) {
    if (partition.time_bucket.indices[j] === index) {
      return partition.time_bucket.headers[j];
    }
  }
}

function makeLink(link, value, linkColor) {
  return (
    '<a href="' +
    link +
    '" style="text-decoration:none;font-weight:500;color:' +
    linkColor +
    ';">' +
    (value ? value : link) +
    "</a>"
  );
}

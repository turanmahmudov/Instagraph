function formatString(string)
{
    var textColor = hexToRgb(styleApp.common.linkColor)

    string = string.replace(/@([a-zA-Z0-9._]*)/g,'<a href="user://$1" style="text-decoration:none;color:'+textColor+';">@$1</a>');
    string = string.replace(/#(\S*)/g,'<a href="tag://$1" style="text-decoration:none;color:'+textColor+';">#$1</a>');

    return string;
}

function formatRichTextUsers(string)
{
    var regex = /{([a-zA-Z0-9._|?=\\%&]*)}/g;
    var match

    while (match = regex.exec(string)) {
        var user_id = match[1].split('user?id=')[1]
        var user_name = match[1].split('|')[0]

        if (typeof user_id != 'undefined') {
            string = string.replace(match[0], '<a href="userid://'+user_id+'" style="text-decoration:none;font-weight:500;color:'+hexToRgb(styleApp.common.textColor)+';">'+user_name+'</a>')
        } else {
            string = string.replace(match[0], '<a href="user://'+user_name+'" style="text-decoration:none;font-weight:500;color:'+hexToRgb(styleApp.common.textColor)+';">'+user_name+'</a>')
        }
    }

    return string
}

function formatUser(string)
{
    var textColor = styleApp.common.textColor

    return '<a href="user://'+string+'" style="text-decoration:none;font-weight:500;color:'+textColor+';">'+string+'</a>';
}

function makeLink(string)
{
    return '<a href="'+string+'" style="text-decoration:none;font-weight:500;color:rgb(0,0,0);">'+string+'</a>';
}

function getBestImage(imageObject, width) {
    var closest = typeof imageObject[0] != 'undefined' ? imageObject[0] : {"width":0, "height":0, "url":""};

    for(var i = 0; i < imageObject.length; i++){
        if(imageObject[i].width >= width && imageObject[i].width < closest.width) closest = imageObject[i];
    }

    return closest;
}

function milisecondsToString(miliseconds, short, timestamp) {
    if (timestamp) {
        miliseconds = miliseconds/1000000;
    }

    try {
        //get different date time initials.
        var myDate = new Date();
        var difference_ms = myDate.getTime() - miliseconds * 1000;
        //take out milliseconds
        difference_ms = difference_ms / 1000;
        var seconds = Math.floor(difference_ms % 60);
        difference_ms = difference_ms / 60;
        var minutes = Math.floor(difference_ms % 60);
        difference_ms = difference_ms / 60;
        var hours = Math.floor(difference_ms % 24);
        difference_ms = difference_ms / 24;
        var days = Math.floor(difference_ms % 7);
        difference_ms = difference_ms / 7;
        var weeks = Math.floor(difference_ms);

        //remove weeks if it exceeds the month limit ie. 4weeks+2days.
        var months = 0;
        if ((weeks === 4 && days >= 2) || (weeks > 4)) {
            difference_ms = difference_ms * 7;
            days = Math.floor(difference_ms % 30);
            difference_ms = difference_ms / 30;
            months = Math.floor(difference_ms);
            weeks = 0;
        }
        //check and return the largest value of date time initialized.
        if (months > 0) {
            return short ? i18n.tr("%1M").arg(months) : i18n.tr("%1 MONTH AGO", "%1 MONTHS AGO", months).arg(months);
        } else if (weeks !== 0) {
            return short ? i18n.tr("%1w").arg(weeks) : i18n.tr("%1 WEEK AGO", "%1 WEEKS AGO", weeks).arg(weeks);
        } else if (days !== 0) {
            return short ? i18n.tr("%1d").arg(days) : i18n.tr("%1 DAY AGO", "%1 DAYS AGO", days).arg(days);
        } else if (hours !== 0) {
            return short ? i18n.tr("%1h").arg(hours) : i18n.tr("%1 HOUR AGO", "%1 HOURS AGO", hours).arg(hours);
        } else if (minutes !== 0) {
            return short ? i18n.tr("%1m").arg(minutes) : i18n.tr("%1 MINUTE AGO", "%1 MINUTES AGO", minutes).arg(minutes);
        } else if (seconds !== 0) {
            return short ? i18n.tr("%1s").arg(seconds) : i18n.tr("%1 SECOND AGO", "%1 SECONDS AGO", seconds).arg(seconds);
        }
    } catch (e) {
        console.log(e);
    }
}

function numFormatter(num, digits) {
  var si = [
    { value: 1, symbol: "" },
    { value: 1E3, symbol: "K" },
    { value: 1E6, symbol: "M" },
    { value: 1E9, symbol: "G" },
    { value: 1E12, symbol: "T" },
    { value: 1E15, symbol: "P" },
    { value: 1E18, symbol: "E" }
  ];
  var rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
  var i;
  for (i = si.length - 1; i > 0; i--) {
    if (num >= si[i].value) {
      break;
    }
  }
  return (num / si[i].value).toFixed(digits).replace(rx, "$1") + si[i].symbol;
}

function toObject(arr) {
    var rv = {};
    for (var i = 0; i < arr.length; ++i)
        if (arr[i] !== undefined) rv[i] = arr[i];
    return rv;
}

function objectLength(obj) {
  var result = 0;
  for(var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
      result++;
    }
  }
  return result;
}

function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);

  return result ? "rgb("+parseInt(result[1], 16)+","+parseInt(result[2], 16)+","+parseInt(result[3], 16)+")" : null;
}

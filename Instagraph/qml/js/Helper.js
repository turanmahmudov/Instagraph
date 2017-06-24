function formatString(string)
{
    //var user_reg = "/@(\w*)/g";
    var user_reg = "/@([a-zA-Z0-9._]*)/g"
    var tag_reg = "/#(\S*)/g"

    string = string.replace(/@([a-zA-Z0-9._]*)/g,'<a href="user://$1" style="text-decoration:none;color:rgb(0,53,105);">@$1</a>');
    string = string.replace(/#(\S*)/g,'<a href="tag://$1" style="text-decoration:none;color:rgb(0,53,105);">#$1</a>');

    return string;
}

function formatUser(string)
{
    return '<a href="user://'+string+'" style="text-decoration:none;font-weight:500;color:rgb(0,0,0);">'+string+'</a>';
}

function getBestImage(imageObject, width) {
    var closest = typeof imageObject[0] != 'undefined' ? imageObject[0] : {"width":0, "height":0, "url":""};

    for(var i = 0; i < imageObject.length; i++){
        if(imageObject[i].width >= width && imageObject[i].width < closest.width) closest = imageObject[i];
    }

    return closest;
}

function milisecondsToString(miliseconds) {
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
        if ((weeks == 4 && days >= 2) || (weeks > 4)) {
            difference_ms = difference_ms * 7;
            days = Math.floor(difference_ms % 30);
            difference_ms = difference_ms / 30;
            months = Math.floor(difference_ms);
            weeks = 0;
        }
        //check and return the largest value of date time initialized.
        if (months > 0) {
            return i18n.tr("%1 MONTH AGO", "%1 MONTHS AGO", months).arg(months);
        } else if (weeks != 0) {
            return i18n.tr("%1 WEEK AGO", "%1 WEEKS AGO", weeks).arg(weeks);
        } else if (days != 0) {
            return i18n.tr("%1 DAY AGO", "%1 DAYS AGO", days).arg(days);
        } else if (hours != 0) {
            return i18n.tr("%1 HOUR AGO", "%1 HOURS AGO", hours).arg(hours);
        } else if (minutes != 0) {
            return i18n.tr("%1 MINUTE AGO", "%1 MINUTES AGO", minutes).arg(minutes);
        } else if (seconds != 0) {
            return i18n.tr("%1 SECOND AGO", "%1 SECONDS AGO", seconds).arg(seconds);
        }
    } catch (e) {
        console.log(e);
    }
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

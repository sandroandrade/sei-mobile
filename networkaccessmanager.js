var httpRequest = new XMLHttpRequest();

function get(url) {
    httpRequest.open("GET", url);
    httpRequest.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    httpRequest.send();
}

function post(url, params) {
    httpRequest.open("POST", url);
    httpRequest.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    httpRequest.send(params);
}

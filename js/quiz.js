var path = "localhost:8080"

window.onload = function()
{
    document.getElementById('a').onclick = function ()
    {
        getResultOf('a');
    }
    document.getElementById('b').onclick = function ()
    {
        getResultOf('b');
    }
    document.getElementById('c').onclick = function ()
    {
        getResultOf('c');
    }
    document.getElementById('d').onclick = function ()
    {
        getResultOf('d');
    }
    document.getElementById('nextButton').onclick = function ()
    {
        getNextQuiz();
    }
}

function getResultOf(choice) {
    var result = true;

    var answerDiv = document.getElementById("answer");
    var nextDiv = document.getElementById("nextButton");

    postJsonData("/quiz4/answer", JSON.stringify("A"));

    answerDiv.style.visibility = "visible";
    nextDiv.style.visibility = "visible";
    if(result != true)  //誤答の場合
    {
        answerDiv.style.backgroundColor = "#cc4444aa";
    }
}

function getNextQuiz()
{
    var answerDiv = document.getElementById("answer");
    var nextDiv = document.getElementById("nextButton");
    answerDiv.style.visibility = "hidden";
    nextDiv.style.visibility = "hidden";

    getJsonData("/quiz4/get");
}

function getJsonData(url)
{
    xhr = new XMLHttpRequest;
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = () => {
        console.log(xhr.responseText);
    }
    xhr.onerror = () => {
        console.log(xhr.status);
    }
    xhr.send(null);
}

function postJsonData(url, jsondata)
{
    xhr = new XMLHttpRequest;
    xhr.open('post', url);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = () => {
        console.log(xhr.status);
    }
    xhr.onerror = () => {
        console.log(xhr.status);
    }
    xhr.send(jsondata);
}
var path = "localhost:8080"
var solvingQuiz;

window.onload = function()
{
    getNextQuiz();
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
    // 解答表示
    var answerDiv = document.getElementById("answerblock");
    var nextDiv = document.getElementById("nextButton");
    
    var selected = document.getElementById(choice);
    if (selected.textContent == solvingQuiz.answer)
    {
        answerDiv.style.backgroundColor = "#44ccccaa";
    }
    else
    {
        answerDiv.style.backgroundColor = "#cc4444aa";
    }


    answerDiv.style.visibility = "visible";
    nextDiv.style.visibility = "visible";
}

function getNextQuiz()
{
    var answerDiv = document.getElementById("answerblock");
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
        var rec = JSON.parse(xhr.response);
        var statementDiv = document.getElementById("problemSentence");
        var aDiv = document.getElementById("a");
        var bDiv = document.getElementById("b");
        var cDiv = document.getElementById("c");
        var dDiv = document.getElementById("d");
        var answerDiv = document.getElementById("answer");
        var expDiv = document.getElementById("explanation");
        statementDiv.textContent = rec.statement;
        aDiv.textContent = rec.a;
        bDiv.textContent = rec.b;
        cDiv.textContent = rec.c;
        dDiv.textContent = rec.d;
        answerDiv.textContent = rec.answer;
        expDiv.textContent = rec.explanation;

        solvingQuiz = rec;
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
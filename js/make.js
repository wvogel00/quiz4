window.onload = function()
{
    document.getElementById('makeButton').onclick = function ()
    {
        makeQuiz();
    }
}

function makeQuiz() {
    prob = document.getElementById("problem");
    a = document.getElementById("a");
    b = document.getElementById("b");
    c = document.getElementById("c");
    d = document.getElementById("d");
    answer = document.getElementById("answer");
    exp = document.getElementById("explanation");
    
    if(existEmptyInput(prob,a,b,c,d))
    {
        alert ("入力されていない項目があります（解説以外は必須項目です）")
        return;
    }
    else
    {
        var quiz = makeQuizObj(prob,a,b,c,d,answer,exp);
        postJsonData("/quiz4/make",JSON.stringify(quiz));
    }
}

function makeQuizObj(prob,a,b,c,d,answer,exp)
{
    var quiz = new Object();
    quiz.statement = prob.value;
    quiz.a = a.value;
    quiz.b = b.value;
    quiz.c = c.value;
    quiz.d = d.value;
    var answerDiv = document.getElementById(answer.value);
    quiz.answer = answerDiv.value;
    quiz.explanation = exp.value;

    return quiz;
}

function existEmptyInput(prob,a,b,c,d)
{
    return (!prob.value || !a.value || !b.value || !c.value || !d.value);
}
function postJsonData(url, jsondata)
{
    xhr = new XMLHttpRequest;
    xhr.open('post', url);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = () => {
        console.log(xhr.status);
        console.log(jsondata);
    }
    xhr.onerror = () => {
        console.log(xhr.status);
    }
    xhr.send(jsondata);
}
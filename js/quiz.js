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
}

function getResultOf(choice) {
    var result = true;

    var answerDiv = document.getElementById("answer");
    answerDiv.style.visibility = "visible";
    if(result != true)  //誤答の場合
    {
        answerDiv.style.backgroundColor = "#cc4444aa";
    }
}
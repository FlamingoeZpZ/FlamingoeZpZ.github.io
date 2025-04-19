
const Processing = document.getElementById("JavaProcessing");
const Unity = document.getElementById("C#Unity");
const Unreal = document.getElementById("C++Unreal");
const Other = document.getElementById("Other");
const JavaColor = document.getElementById("JavaButton").style.backgroundColor;
const UnityColor = document.getElementById("UnityButton").style.backgroundColor;
const UnrealColor = document.getElementById("UnrealButton").style.backgroundColor;
const OtherColor = document.getElementById("OtherButton").style.backgroundColor;
const Body = document.getElementById("core");

function coreMain()
{
    showProcessing();
}

function showProcessing() {
    Processing.classList.add("show");
    Unity.classList.remove("show");
    Unreal.classList.remove("show");
    Other.classList.remove("show");

    Body.style.backgroundColor = JavaColor;
}

function showUnity() {
    Processing.classList.remove("show");
    Unity.classList.add("show");
    Unreal.classList.remove("show");
    Other.classList.remove("show");

    Body.style.backgroundColor = UnityColor;

}

function showUnreal() {
    Processing.classList.remove("show");
    Unity.classList.remove("show");
    Unreal.classList.add("show");
    Other.classList.remove("show");

    Body.style.backgroundColor = UnrealColor;

}

function showOther() {
    Processing.classList.remove("show");
    Unity.classList.remove("show");
    Unreal.classList.remove("show");
    Other.classList.add("show");
    
    Body.style.backgroundColor = OtherColor;
}
 
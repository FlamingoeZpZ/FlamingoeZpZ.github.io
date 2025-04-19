//Parts are AI Generated. I'm a game developer, spending hours in JS context does not make sense.

const Processing = document.getElementById("JavaProcessing");
const Unity = document.getElementById("C#Unity");
const Unreal = document.getElementById("C++Unreal");
const Other = document.getElementById("Other");

function coreMain()
{
    showProcessing();
}

function showProcessing() {
    Processing.classList.add("show");
    Unity.classList.remove("show");
    Unreal.classList.remove("show");
    Other.classList.remove("show");
}

function showUnity() {
    Processing.classList.remove("show");
    Unity.classList.add("show");
    Unreal.classList.remove("show");
    Other.classList.remove("show");
}

function showUnreal() {
    Processing.classList.remove("show");
    Unity.classList.remove("show");
    Unreal.classList.add("show");
    Other.classList.remove("show");
}

function showOther() {
    Processing.classList.remove("show");
    Unity.classList.remove("show");
    Unreal.classList.remove("show");
    Other.classList.add("show");
}

// Remove all window.onclick handlers and use addEventListener instead
document.addEventListener('click', function(event) {
    if (!event.target.closest('.dropdown')) {
        var dropdowns = document.getElementsByClassName("dropdown-content");
        for (var i = 0; i < dropdowns.length; i++) {
            var openDropdown = dropdowns[i];
            if (openDropdown.classList.contains('show')) {
                openDropdown.classList.remove('show');
            }
        }
    }
});

const secondaryShaders = [
    //"Constant",
    //"Bubbles",
    "Stars",
];

let id = -1;

async function loadShaderSource(url) {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`Failed to load shader: ${response.statusText}`);
    }
    return await response.text();
}

async function chooseRandomShader() {
    let newId = Math.floor(Math.random() * secondaryShaders.length);
    if(id === newId) newId = (newId + 1)%secondaryShaders.length;
    return await loadShader(newId);
}

async function loadNextShader()
{
    return await loadShader((id + 1)%secondaryShaders.length)
}

async function loadShader(declared)
{
    id = declared;
    const shader = secondaryShaders[id];
    console.log('Assets/Shaders/' + shader + '.frag');
    return await loadShaderSource('Assets/Shaders/' + shader + '.frag');
}

async function main() {
    const canvas = document.getElementById("glCanvas");
    const gl = canvas.getContext("webgl");
    
    coreMain();

    if (!gl) {
        alert("WebGL not supported!");
        return;
    }

    async function loadNewShader() {
        // Cleanup old shaders and program
        if (program) {
            gl.useProgram(null);
            gl.deleteProgram(program);
        }
        if (fragmentShader) {
            gl.deleteShader(fragmentShader);
        }

        const newFragmentShaderSource = await loadNextShader();
        fragmentShader = compileShader(gl, newFragmentShaderSource, gl.FRAGMENT_SHADER);
        if (!fragmentShader) return;

        program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);

        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            console.error("Program failed to link:", gl.getProgramInfoLog(program));
            return;
        }

        gl.useProgram(program);

        // Update attribute/uniform locations
        positionLocation = gl.getAttribLocation(program, "a_position");
        resolutionLocation = gl.getUniformLocation(program, "u_resolution");
        timeLocation = gl.getUniformLocation(program, "u_time");
    }

    // Expose to window so HTML button can call it
    window.loadNewShader = loadNewShader;

    window.addEventListener("beforeunload", () => {
        if (gl) {
            if (program) {
                gl.useProgram(null);
                gl.deleteProgram(program);
            }
            if (fragmentShader) {
                gl.deleteShader(fragmentShader);
            }
            if (vertexShader) {
                gl.deleteShader(vertexShader);
            }
        }
    });

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    // Vertex Shader Source
    const vertexShaderSource = `
        attribute vec2 a_position;
        void main() {
            gl_Position = vec4(a_position, 0.0, 1.0);
        }
    `;



    // Compile Shader Helper
    function compileShader(gl, source, type) {
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            console.error(gl.getShaderInfoLog(shader));
            return null;
        }
        return shader;
    }



    // Load Fragment Shader Source from External File
    let fragmentShaderSource = await chooseRandomShader();

    // Compile Shaders
    const vertexShader = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER);
    let fragmentShader = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER);

    let program = gl.createProgram();

    let positionLocation = 0;
    let resolutionLocation = 0;
    let timeLocation = 0;


    createProgram();
    function createProgram()
    {
        // Create Program
        program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);
        gl.useProgram(program);

        createLocations();
    }


    function createLocations()
    {
        positionLocation = gl.getAttribLocation(program, "a_position");

        // Uniforms
        resolutionLocation = gl.getUniformLocation(program, "u_resolution");
        timeLocation = gl.getUniformLocation(program, "u_time");
    }


    // Fullscreen Quad Setup
    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
        -1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1
    ]), gl.STATIC_DRAW);



    function render(time) {
        gl.enableVertexAttribArray(positionLocation);
        gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);

        const displayWidth = canvas.clientWidth;
        const displayHeight = canvas.clientHeight;

        // Check if the canvas size needs to be updated
        if (canvas.width !== displayWidth || canvas.height !== displayHeight) {
            canvas.width = displayWidth;
            canvas.height = displayHeight;
            gl.viewport(0, 0, canvas.width, canvas.height); // Update the viewport
        }

        gl.uniform2f(resolutionLocation, canvas.width, canvas.height);
        gl.uniform1f(timeLocation, time * 0.001);

        gl.drawArrays(gl.TRIANGLES, 0, 6);
        requestAnimationFrame(render);
    }
    requestAnimationFrame(render);
}



main().catch(console.error);
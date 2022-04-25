/**
 * jspsych-darkroom
 * brad rogers
 *
 *console command to display underlying map:
 *document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.display = 'none');
 *document.querySelector('#jspsych-darkroom-done-btn').disabled=false
 */

jsPsych.plugins['darkroom-dig'] = (function() {

  var plugin = {};

  jsPsych.pluginAPI.registerPreload('darkroom');

  plugin.info = {
    name: 'darkroom',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'match',
        default: true,
        description: 'decide whether the maps are force match or random mismatch: true/false'
      },
      room_height: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Stimulus height',
        default: 400,
        description: 'Height of images in pixels.'
      },
      room_width: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Stimulus width',
        default: 300,
        description: 'Width of images in pixels'
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'It can be used to provide a reminder about the action the subject is supposed to take.'
      },
      prompt_location: {
        type: jsPsych.plugins.parameterType.SELECT,
        pretty_name: 'Prompt location',
        options: ['above', 'below'],
        default: 'above',
        description: 'Indicates whether to show prompt "above" or "below" the sorting area.'
      },
      button_label: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Button label',
        default: 'Continue',
        description: 'The text that appears on the button to continue to the next trial.'
      },
      sellMap: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Allow sell map',
        default: false,
        description: 'Whether to allow the participant to sell the map.'
      },
      mapReward: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Map reward value',
        default: 20,
        description: 'The percent of the total prize value (as integer) that the participant receives for selling the map.'
      },
      currency: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'currency text',
        default: $,
        description: 'currency text symbol'
      },
      decrementMapVal: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Decrement map value',
        default: false,
        description: 'Whether to decrement map value with each map click.'
      },
      mapDecrements: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Map decrements',
        default: 20,
        description: 'Number of decrements of map before reaching zero'
      },
      revealSize: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Reveal world size',
        default: 0,
        description: 'x by x block of Sprite World that is initially revealed, not inculding the Sprite'
      },
      gap: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Gap',
        default: 20,
        description: 'The space (in pixels) around each room in the arena.'
      },
      Xgrid: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'X grid items',
        default: 5,
        description: 'The number of grid items in the horizontal direction for each room.'
      },
      Ygrid: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Y grid items',
        default: 5,
        description: 'The number of grid items in the vertical direction for each room.'
      },
      maxTranslation: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'maximum translation',
        default: 0,
        description: 'The maximum number of grid blocks that the surrogate may be translated. Must be less than half of the minimum grid dimension blox.'
      },
      maxPrize: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'maximum prize',
        default: 100,
        description: 'The starting value of the prize.'
      },
      primaryDec: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'primary decrement',
        default: 2,
        description: 'The decrease in prize value with each click in the primary room.'
      },
      surrogateDec: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'surrogateDecrement',
        default: 1,
        description: 'The decrease in prize value with each click in the surrogate room.'
      },
      digDec: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'digDecrement',
        default: 10000,
        description: 'The cost to dig.'
      },
      nodigDec: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'digDecrement',
        default: 1000,
        description: 'The cost to not dig (i.e. walk away).'
      },
      mapDir: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'map directory',
        default: 1,
        description: 'The directory number of the map images to use (e.g., for mapDir==3 the directory is img/map/m3/ )'
      },
      exploreDelay: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'explore delay',
        default: 0,
        description: 'Millisecond delay when clicking in the explore pane (rather than the map pane)'
      },
      exploreDelayMap: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'explore delay map',
        default: 0,
        description: 'Millisecond delay when clicking in the map pane (rather than the map pane)'
      },
      degreesFree: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'explore delay',
        default: 0,
        description: 'Degrees of freedom to shift a matching map. 0 for none. 1 for up to maxTranslation spaces in either direction. 2 for up to maxTranslation spaces in both directions'
      },
      seed:{
        type: jsPsych.plugins.parameterType.NUMBER,
        pretty_name: 'seed',
        default: [],
        description: 'seeds for predefined stimuli'
      },
      revealLoc: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'reveal location',
        default: [],
        description: 'the upper left location of the reveal as a 1x2 array [x,y]'
      },
      targetLoc: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'target location',
        default: [],
        description: 'the location of the target 1x2 array [x,y]'
      },
      mtargetLoc: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Map target location',
        default: [],
        description: 'the location of the MAP target 1x2 array [x,y]'
      },
      totPrizeInit: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'intial total',
        default: 100000,
        description: 'how much bank to begin with'
      },

    }
  }

  plugin.trial = function(display_element, trial) {

    var start_time = (new Date()).getTime();

    var html = "";
    // check if there is a prompt and if it is shown above
    if (trial.prompt !== null && trial.prompt_location == "above") {
      html += trial.prompt;
    }

    window.waiting = false

    window.prize = (typeof window.prize === 'undefined' || window.prize == 0) ? trial.maxPrize : window.prize;
    window.totprize = (typeof window.totprize === 'undefined' || window.totprize == 0) ? trial.totPrizeInit : window.totprize;
    window.mapVal = trial.maxPrize * trial.mapReward / 100;

    html += "<div id='prize-container' style='font-size:40pt'><br></div>"
    html += "<div id='prize-container' style='font-size:40pt'><br> Treasure Value: "+trial.currency+"<span id='prize-el'>" + numberWithCommas(window.prize) + " </span><br><br></div>"


    // html += "<div id='prize-container' style='font-size:40pt'><br><img src='img/sprite/mystery.png' height='50px'></img> "+trial.currency+"<span id='prize-el'>" + numberWithCommas(window.prize) + " </span><img src='img/sprite/mystery.png' height='50px'></img><br><br></div>"

    var arena_width = 2 * trial.room_width + 4 * trial.gap;
    var arena_height = trial.room_height + 2 * trial.gap;

    var map_button = ''
    // window.sellMapLabel = '<b>SELL MAP</b> <br>(gain +'+trial.currency'+numberWithCommas(window.mapVal)+')'
    // if (trial.sellMap) {
    //   map_button = '<button id="jspsych-darkroom-sellmap-btn" class="jspsych-btn" style="margin:30px; background-color:orange">'+window.sellMapLabel+'</button>'
    // }

    window.digLabel = '<b>DIG FOR TREASURE</b> <br> I have a good feeling. <br> (costs -'+trial.currency+numberWithCommas(trial.digDec)+')'
    dig_button = '<button id="jspsych-darkroom-dig-btn" class="jspsych-btn" style="margin:30px; background-color:green; color:white">'+window.digLabel+'</button>'

    window.nodigLabel = '<b>TRY ANOTHER PLANET</b> <br> I have a bad feeling. <br>(walk away -'+trial.currency+numberWithCommas(trial.nodigDec)+')'
    nodig_button = '<button id="jspsych-darkroom-nodig-btn" class="jspsych-btn" style="margin:30px; background-color:red; color:white">'+window.nodigLabel+'</button>'


    html += '<table><tr>' +
      '<td></td>'+
      '<td><div id ="jspsych-darkroom-clickcosts" style="font-size:20pt"> <b>click left pane: -'+trial.currency+trial.primaryDec/1000+',000 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; click right pane: -'+trial.currency+ trial.surrogateDec/1000+',000</b></div></td>'+
      '<td></td>'+
      '</tr><tr>'+
      '<td>Check the surface of the planet<br><img src="img/sprite/balloon.png" height="120px"></img>'+ //<br>Go: -'+trial.currency' + numberWithCommas(trial.primaryDec) + '<br>(click left pane)</td>' +
      '<td><div id="jspsych-darkroom-arena" class="jspsych-darkroom-arena" style="position: relative; width:' + arena_width + 'px; height:' + arena_height + 'px; border:2px solid #444;"></div></td>' +
      '<td><br>Uncover part of the map<br><img src="img/sprite/merchant.png" height="150px"></img><br>'+//<br>Look: -'+trial.currency' + numberWithCommas(trial.surrogateDec) + '<br>(click right pane) <br>' +
      '</td>' +
      '</tr></table>';



    // check if prompt exists and if it is shown below
    if (trial.prompt !== null && trial.prompt_location == "below") {
      html += trial.prompt;
    }

    // set X and Y random translations
    var Xtrans = (Math.round(2 * trial.maxTranslation * Math.random()) - trial.maxTranslation);
    var Ytrans = (Math.round(2 * trial.maxTranslation * Math.random()) - trial.maxTranslation);

    // overwrite X and Y translations based on degrees of freedom
    if (trial.degreesFree == 0){
      Xtrans = 0
      Ytrans = 0
    } else if (trial.degreesFree == 1) {
      if (Math.random() > 0.5){
        Xtrans = 0
      }else{
        Ytrans=0
      }
    }

    var targXgrid = trial.Xgrid - Math.abs(Xtrans);
    var targYgrid = trial.Ygrid - Math.abs(Ytrans);

    if (trial.targetLoc.length >0){
      target = trial.targetLoc //target = trial.targetLoc
    } else {
    var target = targ(targXgrid, targYgrid, Xtrans, Ytrans);}
    //console.log(target)
    if (trial.mtargetLoc.length >0){
      mtarget = trial.mtargetLoc
    } else {
    var mtarget = targ(targXgrid, targYgrid, Xtrans, Ytrans);}
    target = mtarget


    display_element.innerHTML = html;
    var coords = {
      x: (trial.gap + (i * (2 * trial.gap + trial.room_width))),
      y: trial.gap
    };

    var mapList = [];


    if (trial.seed.length > 0){
      var seedArr = trial.seed
    } else {
      var seedArr = [Math.random().toFixed(6),Math.random().toFixed(6)] //randomly generate
    }

    var seedlet = seedArr[0]

    for (var i = 0; i < 2; i++) {

      display_element.querySelector("#jspsych-darkroom-arena").innerHTML += '<div id="jspsych-darkroom-room-' + i + '" style="position: relative"></div>';

      var div_width = trial.room_width / trial.Xgrid;
      var div_height = trial.room_height / trial.Ygrid;

      if (trial.stimulus == false && i == 1) {
        seedlet = seedArr[1]
        target = mtarget //targ(targXgrid, targYgrid, Xtrans, Ytrans);
      } else if (trial.stimulus == true){
        seedArr[1] = seedArr[0]
      }

      if (i == 0) {
        var sTarg = [target[0] + (i * -Xtrans), target[1] + (i * -Ytrans)];
        window.targ = sTarg;
      } else {
        var mTarg = [mtarget[0] + (i * -Xtrans), mtarget[1] + (i * -Ytrans)];
      }

      noise.seed(seedlet)
      var scale = 4;
      var refresh_index = true;
      var last_list = [];

      for (var X = 0; X < trial.Xgrid; X++) {
        for (var Y = 0; Y < trial.Ygrid; Y++) {

          var perlin = Math.abs(noise.perlin2((X + i * Xtrans) / scale, (Y + i * Ytrans) / scale) * 2);

          var divmage = map(perlin, [0.4, 0.6], i * trial.mapDir,refresh_index,last_list);
          last_list = divmage[2]
          refresh_index = false;
          mapList.push(divmage[0]);

          // for(let i = 9 — 1; i > 0; i--){
          //   const j = Math.floor(Math.random() * i)
          //   const temp = array[i]
          //   array[i] = array[j]
          //   array[j] = temp
          // }
          // array=array[0:2]

          var div_top = Y * div_height + trial.gap;
          var div_left = X * div_width + trial.gap + i * (trial.room_width + 2 * trial.gap);

          var mapOpacity = 1;

          display_element.querySelector("#jspsych-darkroom-room-" + i).innerHTML += '<div style="background-color: #f4a004;"><img ' +
            'src="' + divmage[0] + '" ' +
            'class="jspsych-darkroom-perlin" ' +
            'id="perlin-R' + i + '-X' + X + '-Y' + Y + '" ' +
            'draggable="false" ' +
            'style="position: absolute; cursor: pointer; width:' + div_width + 'px; height:' + div_height + 'px; top:' + div_top + 'px; left:' + div_left + 'px; opacity:' + (0 ^ i) * mapOpacity + (0 ^ (1 - i)) + ';">' +
            '</img></div>';

          // if (X == target[0] + (i * -Xtrans) && Y == target[1] + (i * -Ytrans) && i == 0) {
          //
          //   display_element.querySelector("#jspsych-darkroom-room-" + i).innerHTML += '<img ' +
          //     'src="' + divmage[1] + '" ' +
          //     'class="jspsych-darkroom-target"' +
          //     'id="truetarget" ' +
          //     'draggable="false" ' +
          //     'style="position: absolute; cursor: pointer; width:' + div_width + 'px; height:' + div_height + 'px; top:' + div_top + 'px; left:' + div_left + 'px;">' +
          //     '</img>';
          // }

          // if (X == target[0] + (i * -Xtrans) && Y == target[1] + (i * -Ytrans) && i == 1) {
          //
          //   display_element.querySelector("#jspsych-darkroom-room-" + i).innerHTML += '<img ' +
          //     'src="img/sprite/xspot.png"' +
          //     'class="jspsych-darkroom-target"' +
          //     'id="maptarget" ' +
          //     'draggable="false" ' +
          //     'style="position: absolute; cursor: pointer; width:' + Math.round(div_width*0.5) + 'px; height:' + Math.round(div_height*0.5) + 'px; top:' + div_top + 'px; left:' + div_left + 'px;">' +
          //     '</img>';
          // }

          display_element.querySelector("#jspsych-darkroom-room-" + i).innerHTML += '<div ' +
            'class="jspsych-darkroom-clickable" ' +
            'id="clickable-R' + i + '-X' + X + '-Y' + Y + '" ' +
            'draggable="false" ' +
            'style="position: absolute; cursor:pointer; width:' + div_width + 'px; height:' + div_height + 'px; top:' + div_top + 'px; left:' + div_left + 'px;">' +
            '</div>';

          if ((X == target[0] + (i * -Xtrans) && Y == target[1] + (i * -Ytrans))) {
            if (i==0){
              display_element.querySelector("#clickable-R" + i + "-X" + X + "-Y" + Y).classList.add("target-0");
            } else {
              display_element.querySelector("#clickable-R" + i + "-X" + X + "-Y" + Y).classList.add("target-1");
            }
            var celeb = divmage[1];
          }

          if (i == 0) {
            display_element.querySelector("#clickable-R" + i + "-X" + X + "-Y" + Y).classList.add("primary");
          } else {
            display_element.querySelector("#clickable-R" + i + "-X" + X + "-Y" + Y).classList.add("surrogate");
          }

          if (X == target[0] + (i * -Xtrans) && Y == target[1] + (i * -Ytrans) && i == 1) {
            xs = 0.7
            display_element.querySelector("#jspsych-darkroom-room-" + i).innerHTML += '<img ' +
              'src="img/sprite/xspot.png"' +
              'class="jspsych-darkroom-target"' +
              'id="maptarget" ' +
              'draggable="false" ' +
              'style="position: absolute; cursor: pointer; width:' + div_width*xs + 'px; height:' + div_height*xs + 'px; top:' + (div_top + div_height*(1-xs)/2)  + 'px; left:' + (div_left + div_width*(1-xs)/2) + 'px;">' +
              '</img>';
          }

          if (X == target[0]  + (i * -Xtrans) && Y == target[1] + (i * -Ytrans) && i == 0) {
            xs = 0.7
            display_element.querySelector("#jspsych-darkroom-room-" + i).innerHTML += '<img ' +
              'class="jspsych-darkroom-target"' +
              'id="digtarget" ' +
              'draggable="false" ' +
              'style="position: absolute; cursor: pointer; width:' + div_width*xs + 'px; height:' + div_height*xs + 'px; top:' + (div_top + div_height*(1-xs)/2)  + 'px; left:' + (div_left + div_width*(1-xs)/2) + 'px; display:none;">' +
              '</img>';
          }

        }
      }
    }

    display_element.innerHTML += "<div><br>so far you have earned:<br></div><div style='font-size:28pt'>"+trial.currency+"<span id='total-prize-el'>" + numberWithCommas(window.totprize) + " </span><img src='img/sprite/bank.png' height='50px'></img> <br></div>"
    display_element.innerHTML += dig_button;
    display_element.innerHTML += nodig_button + "<br>";
    display_element.innerHTML += '<button id="jspsych-darkroom-done-btn" class="jspsych-btn" style="margin:30px" disabled="true">' + trial.button_label + '</button>';

    // console.log(seedArr)
    //document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.display = 'none');
    //document.querySelector('#jspsych-darkroom-done-btn').disabled=false


    var bonk = false;
    var clicks = [];
    var reveals = [];

    if (trial.sellMap){
      document.querySelectorAll('.target-1').forEach(el => el.addEventListener('click', function(event) {
        document.getElementById('jspsych-darkroom-sellmap-btn').disabled = true;}))
      if (trial.decrementMapVal){
      document.querySelectorAll('.surrogate').forEach(el => el.addEventListener('click', function(event){
        window.mapVal = Math.max(0, window.mapVal - (trial.maxPrize * trial.mapReward / 100)/trial.mapDecrements);
        window.sellMapLabel = 'SELL MAP (+'+trial.currency+numberWithCommas(window.mapVal)+')'
        document.getElementById('jspsych-darkroom-sellmap-btn').innerHTML = window.sellMapLabel;
      }));
    }};



    if (trial.revealSize > 0){
      var reveal_found = false
      while (!reveal_found){
        if (trial.revealLoc.length > 0 ){
          var reveal_origin = trial.revealLoc
        } else {var reveal_origin = [Math.floor(Math.random()*(trial.Xgrid-trial.revealSize+1)),Math.floor(Math.random()*(trial.Ygrid-trial.revealSize+1))]}
        if (!(window.targ[0]-reveal_origin[0]>=0 & window.targ[0]-reveal_origin[0]<trial.revealSize & window.targ[1]-reveal_origin[1]>=0 & window.targ[1]-reveal_origin[1]<trial.revealSize)){
          reveal_found=true
        } else {reveal_origin = [Math.floor(Math.random()*(trial.Xgrid-trial.revealSize+1)),Math.floor(Math.random()*(trial.Ygrid-trial.revealSize+1))]}
      }
      for (var X = reveal_origin[0]; X < reveal_origin[0] + trial.revealSize; X++) {
        for (var Y = reveal_origin[1]; Y < reveal_origin[1] + trial.revealSize; Y++) {
          document.querySelector('#clickable-R0-X'+X+'-Y'+Y+'').style.display = 'none'
        }
      }
    }

    // document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.addEventListener('click', function(event){
    //   if (waiting == false){
    //     if (window.prize > 0) {
    //       if (el.classList.contains("primary")) {
    //         window.prize = Math.max(window.prize - trial.primaryDec, 0);
    //         document.querySelector('#prize-el').innerHTML = numberWithCommas(window.prize);
    //         window.waiting = true
    //         display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "wait")
    //         el.style.backgroundColor = "black";
    //         window.waiting = setTimeout(function(){
    //           el.style.display = 'none';
    //           clicks.push(el.id);
    //           reveals.push(el.src);
    //           waiting=false
    //           display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "pointer")
    //         },trial.exploreDelay)
    //       } else {
    //         window.prize = Math.max(window.prize - trial.surrogateDec, 0);
    //         document.querySelector('#prize-el').innerHTML = numberWithCommas(window.prize);
    //         display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "wait")
    //         el.style.backgroundColor = "black";
    //         window.waiting = setTimeout(function(){
    //           el.style.display = 'none';
    //           clicks.push(el.id);
    //           reveals.push(el.src);
    //           waiting=false
    //           display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "pointer")
    //         },trial.exploreDelayMap)
    //       }
    //     }
    //   }
    // }));

    document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.addEventListener('click', function(event){
      if (waiting == false){
        if (window.prize > 0) {
          if (el.classList.contains("primary")) {
            window.totprize = Math.max(window.totprize - trial.primaryDec, 0);
            document.querySelector('#total-prize-el').innerHTML = numberWithCommas(window.totprize);
            window.waiting = true
            display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "wait")
            el.style.backgroundColor = "black";
            window.waiting = setTimeout(function(){
              el.style.display = 'none';
              clicks.push(el.id);
              reveals.push(el.src);
              waiting=false
              display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "pointer")
            },trial.exploreDelay)
          } else {
            window.totprize = Math.max(window.totprize - trial.surrogateDec, 0);
            document.querySelector('#total-prize-el').innerHTML = numberWithCommas(window.totprize);
            display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "wait")
            el.style.backgroundColor = "black";
            window.waiting = setTimeout(function(){
              el.style.display = 'none';
              clicks.push(el.id);
              reveals.push(el.src);
              waiting=false
              display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "pointer")
            },trial.exploreDelayMap)
          }
        }
      }
    }));

    window.digdelay = 5000
    document.querySelectorAll('#jspsych-darkroom-dig-btn').forEach(el => el.addEventListener('click', function(event){
      if (waiting == false){
        window.waiting = true
       display_element.querySelectorAll('#jspsych-darkroom-clickcosts').forEach(el => el.style.display = "none")
       document.querySelector('#prize-container').innerHTML = "<div id='prize-container' style='font-size:40pt'><br>DIGGING...<br><br></div>"
        display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "wait")
        display_element.querySelectorAll('.jspsych-btn').forEach(el => el.style.cursor = "wait")
        window.totprize = Math.max(window.totprize - trial.digDec, 0);
        document.querySelector('#total-prize-el').innerHTML = numberWithCommas(window.totprize);
        document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.display = 'none'); //reveal all
        display_element.querySelector("#digtarget").src = "img/sprite/shovel.png"
        display_element.querySelector("#digtarget").style.display = "inline"
        window.waiting = setTimeout(function(){
          if (trial.stimulus){
            window.totprize = Math.max(window.totprize + trial.maxPrize, 0);
            document.querySelector('#total-prize-el').innerHTML = numberWithCommas(window.totprize);
            document.querySelector('#prize-container').innerHTML = "<div id='prize-container' style='font-size:40pt; color:green'><br>YOU FOUND <span id='prize-el'>"+trial.currency + numberWithCommas(window.prize) + " </span> !!!<br><br></div>"
            display_element.querySelector("#digtarget").src = "img/sprite/treasurebig.png"
          } else {
            document.querySelector('#prize-container').innerHTML = "<div id='prize-container' style='font-size:40pt; color:red'><br>YOU FOUND NOTHING.<br><br></div>"
            display_element.querySelector("#digtarget").style.display = "none"
          }
          clicks.push(el.id);
          reveals.push(el.src);
          display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "pointer")
          display_element.querySelectorAll('.jspsych-btn').forEach(el => el.style.cursor = "pointer")
          document.querySelectorAll('.jspsych-btn').forEach(el => el.disabled = true);
          display_element.querySelector('#jspsych-darkroom-done-btn').disabled = false;
          document.querySelectorAll('.jspsych-btn').forEach(el => el.style.backgroundColor = 'gray');
          display_element.querySelector('#jspsych-darkroom-done-btn').style.backgroundColor = 'lightgreen';
          document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.display = 'none'); //reveal all
          waiting=false
          bonk = true;
        },window.digdelay)
    }}));


    window.nodigdelay = 1000
    document.querySelectorAll('#jspsych-darkroom-nodig-btn').forEach(el => el.addEventListener('click', function(event){
      if (waiting == false){
       window.waiting = true
       display_element.querySelectorAll('#jspsych-darkroom-clickcosts').forEach(el => el.style.display = "none")
       document.querySelector('#prize-container').innerHTML = "<div id='prize-container' style='font-size:40pt'><br>WALKING AWAY...<br><br></div>"
        display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "wait")
        display_element.querySelectorAll('.jspsych-btn').forEach(el => el.style.cursor = "wait")
        window.totprize = Math.max(window.totprize - trial.nodigDec, 0);
        document.querySelector('#total-prize-el').innerHTML = numberWithCommas(window.totprize);
        window.waiting = setTimeout(function(){
          clicks.push(el.id);
          reveals.push(el.src);
          display_element.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.cursor = "pointer")
          display_element.querySelectorAll('.jspsych-btn').forEach(el => el.style.cursor = "pointer")
          document.querySelectorAll('.jspsych-btn').forEach(el => el.disabled = true);
          display_element.querySelector('#jspsych-darkroom-done-btn').disabled = false;
          document.querySelectorAll('.jspsych-btn').forEach(el => el.style.backgroundColor = 'gray');
          display_element.querySelector('#jspsych-darkroom-done-btn').style.backgroundColor = 'lightgreen';
          document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.display = 'none'); //reveal all
          waiting=false
          bonk = true;
        },window.nodigdelay)
    }}));


if (trial.sellMap == true){
    document.getElementById('jspsych-darkroom-sellmap-btn').addEventListener('click', function(event) {
      window.totprize = window.totprize + window.mapVal;
      document.getElementById('total-prize-el').innerHTML = numberWithCommas(window.totprize);
      document.getElementById('jspsych-darkroom-sellmap-btn').disabled = true;
      clicks.push('sell_map');
      document.querySelectorAll('.surrogate').forEach(function(el) {
        el.style.display = 'inline'
        el.style.backgroundColor = 'lightgrey'
        el.parentNode.replaceChild(el.cloneNode(true),el)
      });
    });}

    // document.querySelectorAll('.target-0').forEach(el => el.addEventListener('click', function(event) {
    //   if (bonk == false) {
    //     display_element.querySelector('#jspsych-darkroom-done-btn').disabled = false;
    //     document.querySelectorAll('.jspsych-darkroom-clickable').forEach(el => el.style.display = 'none');
    //     window.totprize = Math.max(window.totprize + window.prize, 0);
    //     document.querySelector('#total-prize-el').innerHTML = numberWithCommas(window.totprize);
    //     window.prize = 0;
    //     document.querySelector('#prize-el').innerHTML = numberWithCommas(window.prize);
    //     clicks.push(el.id);
    //     document.querySelector('#prize-container').innerHTML = "<div id='prize-container' style='font-size:40pt'><img src='" + celeb + "' height='60px'></img> <img height='60px' src='img/sprite/celeb.png'</img> <img src='" + celeb + "' height='60px'></img><br><br></div>"
    //   }
    // }));

    display_element.querySelector('#jspsych-darkroom-done-btn').addEventListener('click', function() {
      var end_time = (new Date()).getTime();
      var rt = end_time - start_time;

      // gather data
      var trial_data = {
        "clicks": JSON.stringify(clicks),
        "mapList": JSON.stringify(mapList),
        "rt": rt,
        "match": JSON.stringify(trial.stimulus),
        "sTarg": JSON.stringify(sTarg),
        "mTarg": JSON.stringify(mTarg),
        "xGrid": JSON.stringify(trial.Xgrid),
        "yGrid": JSON.stringify(trial.Ygrid),
        "maxTrans": JSON.stringify(trial.maxTranslation),
        "maxPrize": JSON.stringify(trial.maxPrize),
        "primaryDec": JSON.stringify(trial.primaryDec),
        "surrogateDec": JSON.stringify(trial.surrogateDec),
        "mapDir": JSON.stringify(trial.mapDir),
        "revealSize": JSON.stringify(trial.revealSize),
        "revealLoc": JSON.stringify(reveal_origin),
        "exploreDelay": JSON.stringify(trial.exploreDelay),
        "degreesFree": JSON.stringify(trial.degreesFree),
        "seedArray":JSON.stringify(seedArr),
      };

      // advance to next part
      display_element.innerHTML = '';
      jsPsych.finishTrial(trial_data);
    });

    function targ(txg, tyg, xtr, ytr) {
      var t = Math.floor(txg * tyg * Math.random());
      var xt = (t % txg) + Math.max(0, xtr);
      var yt = Math.floor(t / txg) + Math.max(0, ytr);
      var out = [xt, yt];
      return out
    };

    // function map(x, y, m) {
    //   if (x < y[0]) {
    //     return ['img/map/m' + m + '/map1.png', 'img/sprite/map1T.png']
    //   } else if (x < y[1]) {
    //     return ['img/map/m' + m + '/map2.png', 'img/sprite/map2T.png']
    //   } else {
    //     return ['img/map/m' + m + '/map3.png', 'img/sprite/map3T.png']
    //   }
    // };

    function map(x, y, m, refresh,last_list) {
      // const fs = require('fs');
      // const dir = 'img/map/m' + m ;
      // fs.readdir(dir, (err, files) => {
      //   var file_count=files.length;
      // });
      if (m==5){
        var file_count = 9;
      } else {
        var file_count = 3;
      }
      if (refresh == true){
        var ordered_file_index = Array(file_count).fill().map((element, index) => index + 1);
        if (m > 0){
          var applied_file_index = jsPsych.randomization.shuffle(ordered_file_index)
        } else {
          var applied_file_index = ordered_file_index
        }
      } else {
        applied_file_index = last_list;
      }
      console.log(applied_file_index)
      if (x < y[0]) {
        return ['img/map/m' + m + '/map'+applied_file_index[0]+'.png', 'img/sprite/map1T.png',applied_file_index]
      } else if (x < y[1]) {
        return ['img/map/m' + m + '/map'+applied_file_index[1]+'.png', 'img/sprite/map2T.png',applied_file_index]
      } else {
        return ['img/map/m' + m + '/map'+applied_file_index[2]+'.png', 'img/sprite/map3T.png',applied_file_index]
      }
    };


    function numberWithCommas(x) {
      return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    };


  };
  return plugin;
})();

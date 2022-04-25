/**
 * jspsych-forage01
 * Brad Rogers edit of Josh de Leeuw's button-response
 *
 * plugin for displaying a stimulus and getting a keyboard response
 *
 **/

jsPsych.plugins["forage01"] = (function() {

  var plugin = {};

  plugin.trial = function(display_element, trial) {

    // default trial parameters
    trial.button_html = trial.button_html || '<button class="jspsych-btn">%choice%</button>';
    trial.response_ends_trial = (typeof trial.response_ends_trial === 'undefined') ? true : trial.response_ends_trial;
    trial.timing_stim = trial.timing_stim || -1; // if -1, then show indefinitely
    trial.timing_response = trial.timing_response || -1; // if -1, then wait for response forever
    trial.values = (typeof trial.values === 'undefined') ? "" : trial.values;
    trial.nTrials = (typeof trial.nTrials === 'undefined') ? "" : trial.nTrials;
    trial.trial = (typeof trial.trial === 'undefined') ? "" : trial.trial;

    window.totalearnings =    (typeof window.totalearnings    === 'undefined' || window.trialsRemaining == 0) ? 0 : window.totalearnings;
    window.lastresource =     (typeof window.lastresource     === 'undefined' || window.trialsRemaining == 0) ? "no mineshafts yet" : window.lastresource;
    window.lastactionvalue =  (typeof window.lastactionvalue  === 'undefined' || window.trialsRemaining == 0) ? "0" : window.lastactionvalue;
    window.lastaction =       (typeof window.lastaction       === 'undefined' || window.trialsRemaining == 0) ? "Select your first action." : window.lastaction;
    window.shafts =           (typeof window.shafts           === 'undefined' || window.trialsRemaining == 0) ? [] : window.shafts;
    window.bestresource =     (typeof window.bestresource     === 'undefined' || window.trialsRemaining == 0) ? "no mineshafts yet" : fn_max(window.shafts, trial.values[0]);
    window.trialsRemaining =  (typeof window.trialsRemaining  === 'undefined' || window.trialsRemaining == 0) ? trial.nTrials : window.trialsRemaining;

    function fn_max(arr, key_obj) {
      var max = arr[0];
      for (var i = 1; i<arr.length; i++) {
        if (key_obj[arr[i]] >= key_obj[max]) max = arr[i];
      }
      return max;
    }

    // if any trial variables are functions
    // this evaluates the function and replaces
    // it with the output of the function
    trial = jsPsych.pluginAPI.evaluateFunctionParameters(trial);


    // this array holds handlers from setTimeout calls
    // that need to be cleared if the trial ends early
    var setTimeoutHandlers = [];

    //show trials remaining
    display_element.append('<p class="very-large center-content"><b>MINE MANAGER</b></p>');
    display_element.append('<p class="center-content">Weeks Remaining: <b>'+window.trialsRemaining+ '</b></p>');
    display_element.append('<p class="center-content">Total Earnings: <b>$'+window.totalearnings+ '</b></p>');
    display_element.append('<p class="center-content">Best Mineshaft: <b>'+window.bestresource+ '</b></p>');

    //show prompt
    display_element.append('<p class="center-content">Which action will you take?</p>');

    //display buttons
    var buttons = [];
    if (Array.isArray(trial.button_html)) {
      if (trial.button_html.length == trial.choices.length) {
        buttons = trial.button_html;
      } else {
        console.error('Error in button-response plugin. The length of the button_html array does not equal the length of the choices array');
      }
    } else {
      for (var i = 0; i < trial.choices.length; i++) {
        buttons.push(trial.button_html);
      }
    }


    display_element.append('<div id="jspsych-button-response-btngroup" class="center-content block-center"></div>')
    for (var i = 0; i < trial.choices.length; i++) {
      var str = buttons[i].replace(/%choice%/g, trial.choices[i]);
      $('#jspsych-button-response-btngroup').append(
        $(str).attr('id', 'jspsych-button-response-button-' + i).data('choice', i).addClass('jspsych-button-response-button').on('click', function(e) {
          var choice = $('#' + this.id).data('choice');
          after_response(choice);
        }).prop('disabled', function(u) {
          if ((window.trialsRemaining == trial.nTrials) && (i==trial.choices.length - 1)) return true;
          else return false;
        })
      );
    }


    resourceimg = "img/" + window.lastresource + ".png";

    // display drilling result
    display_element.append('<p class="center-content">'+window.lastaction+' <br> Adding to your earnings: <b>$'+window.lastactionvalue+'</b></p>');

    // display stimulus
    display_element.append($('<img>', {
      src: resourceimg,
      id: 'jspsych-forage01-stimulus',
      class: 'block-center'
    }));


    display_element.append('<br><p class="center-content">Your Mineshafts:</p>');


    for (var i=0; i<window.shafts.length; i++){
        display_element.append('<img src="img/'+window.shafts[i]+'.png" width= "40px" display:"inline" >');
    }

    // store response
    var response = {
      rt: -1,
      button: -1
    };

    // start time
    var start_time = 0;

    // function to handle responses by the subject
    function after_response(choice) {

      // measure rt
      var end_time = Date.now();
      var rt = end_time - start_time;
      response.button = choice;
      response.rt = rt;

      if (choice == 0){
          window.trialsRemaining = window.trialsRemaining - 1;
          window.lastresource = trial.resources[window.shafts.length];
          window.lastaction = "Your last action: <b>discovered " + window.lastresource +"</b>";
          window.shafts.push(window.lastresource)
          window.totalearnings = window.totalearnings;
          window.lastactionvalue = 0;
      } else if (choice == 1){
          window.trialsRemaining = window.trialsRemaining - 1;
          window.lastresource = window.bestresource;
          window.lastaction = "Your last action: <b>extracted " + window.lastresource + "</b>";
          window.totalearnings = window.totalearnings + trial.values[0][window.bestresource];
          window.lastactionvalue = trial.values[0][window.bestresource];
      }

      // after a valid response, the stimulus will have the CSS class 'responded'
      // which can be used to provide visual feedback that a response was recorded
      $("#jspsych-button-response-stimulus").addClass('responded');

      // disable all the buttons after a response
      $('.jspsych-button-response-button').off('click').attr('disabled', 'disabled');

      if (trial.response_ends_trial) {
        end_trial();
      }
    };

    // function to end trial when it is time
    function end_trial() {

      // kill any remaining setTimeout handlers
      for (var i = 0; i < setTimeoutHandlers.length; i++) {
        clearTimeout(setTimeoutHandlers[i]);
      }

      // gather the data to store for the trial
      var trial_data = {
        "rt": response.rt,
        "button_pressed": response.button,
        "trials_remaining": window.trialsRemaining+1,
        "resource_choice": window.lastresource,
        "resource_choice_value": window.lastactionvalue,
        "best_resource": window.bestresource,
        "best_resource_value": trial.values[window.bestresource],
        "total_earnings" : window.totalearnings
      };

      // clear the display
      display_element.html('');

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };

    // start timing
    start_time = Date.now();

    // hide image if timing is set
    if (trial.timing_stim > 0) {
      var t1 = setTimeout(function() {
        $('#jspsych-button-response-stimulus').css('visibility', 'hidden');
      }, trial.timing_stim);
      setTimeoutHandlers.push(t1);
    }

    // end trial if time limit is set
    if (trial.timing_response > 0) {
      var t2 = setTimeout(function() {
        end_trial();
      }, trial.timing_response);
      setTimeoutHandlers.push(t2);
    }

  };

  return plugin;
})();

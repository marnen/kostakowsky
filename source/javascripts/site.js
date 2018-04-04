'use strict';
import ABCJS from 'abcjs';
import $ from 'jquery';
$(() => {
  let abcDiv = $('.abc');
  let abcText = abcDiv.text();
  let tunebook = new ABCJS.TuneBook(abcText);
  abcDiv.hide();
  tunebook.tunes.forEach(tune => {
    let divId = `tune_${tune.id}`;
    let tuneDiv = $(`<div id='${divId}'></div>`);
    tuneDiv.appendTo('body');
    let rendered = ABCJS.renderAbc(divId, tune.abc);
  });
});

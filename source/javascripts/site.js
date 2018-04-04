'use strict';
import ABCJS from 'abcjs';
import $ from 'jquery';

const domId = ({id}) => `tune_${id}`;

const metadata = tunes => tunes.map(tune => {
  const abcLines = tune.abc.split('\n');
  const keys = abcLines.filter(line => line.startsWith('K:')).map(line => line.replace(/^K:\s*/, ''));
  return {id: tune.id, title: tune.title, keys: keys.join(', ')};
});

$(() => {
  const abcDiv = $('.abc');
  const abcText = abcDiv.text();
  const tunebook = new ABCJS.TuneBook(abcText);
  abcDiv.hide();
  const {tunes} = tunebook;
  const contents = $('<ul class="contents"></ul>');
  metadata(tunes).forEach(record => {
    const {id, title, keys} = record;
    const listItem = $('<li></li>').text(`${id}. ${title} (${keys})`);
    const link = $(`<a href='#${domId(record)}'></a>`).html(listItem);
    contents.append(link);
  });
  contents.insertBefore(abcDiv);

  tunes.forEach(tune => {
    const divId = domId(tune);
    const tuneDiv = $(`<div id='${divId}'></div>`);
    tuneDiv.appendTo('body');
    const rendered = ABCJS.renderAbc(divId, tune.abc);
  });
});

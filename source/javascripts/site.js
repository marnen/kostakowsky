'use strict';
import ClipboardJS from 'clipboard/dist/clipboard.min.js'; // see https://github.com/zenorocha/clipboard.js/issues/535 for why the minified version
import $ from 'jquery';

$(() => {
  const contents = $('<ul class="contents"></ul>');
  $('h2').each(function () {
    const h2 = $(this);
    const listItem = $('<li></li>').text(h2.text());
    const link = $(`<a href='#${h2.attr('id')}'></a>`).html(listItem);
    contents.append(link);
  });
  contents.insertAfter($('main h1'));
  $('img').after($('<br /><a href="#">back to top</a>'));
});

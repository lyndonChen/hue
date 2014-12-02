## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
  from desktop.views import commonheader, commonfooter
  from django.utils.translation import ugettext as _
%>


${ commonheader(_('Query'), app_name, user, "68px") | n,unicode }

<script type="text/javascript">
  if (window.location.hash != "") {
    if (window.location.hash.indexOf("notebook") > -1) {
      location.href = "/spark/editor?" + window.location.hash.substr(1);
    }
  }
</script>


<div class="search-bar">
  <div class="pull-right" style="padding-right:50px">
    <a title="${ _('Submit') }" rel="tooltip" data-placement="bottom" data-bind="click: true, css: {'btn': true}">
      <i class="fa fa-play"></i>
    </a>
    <a title="${ _('Edit') }" rel="tooltip" data-placement="bottom" data-bind="click: toggleEditing, css: {'btn': true, 'btn-inverse': isEditing}">
      <i class="fa fa-pencil"></i>
    </a>
    &nbsp;&nbsp;&nbsp;
    % if user.is_superuser:
      <button type="button" title="${ _('Save') }" rel="tooltip" data-placement="bottom" data-loading-text="${ _("Saving...") }"
          data-bind="click: saveNotebook, css: {'btn': true}">
        <i class="fa fa-save"></i>
      </button>
      &nbsp;&nbsp;&nbsp;
      <button type="button" title="${ _('New') }" rel="tooltip" data-placement="bottom" data-loading-text="${ _("New...") }"
          data-bind="click: newNotebook, css: {'btn': true}">
        <i class="fa fa-file-o"></i>
      </button>
      <button type="button" title="${ _('Open') }" rel="tooltip" data-placement="bottom" data-loading-text="${ _("New...") }"
          data-bind="click: newNotebook, css: {'btn': true}">
        <i class="fa fa-folder-open-o"></i>
      </button>      
      <a class="btn" href="${ url('spark:list_notebooks') }" title="${ _('Notebooks') }" rel="tooltip" data-placement="bottom" data-bind="css: {'btn': true}">
        <i class="fa fa-terminal"></i>
      </a>
    % endif
  </div>


  <ul class="nav nav-tabs">
    <!-- ko foreach: notebooks -->
      <li data-bind="css: { active: $parent.selectedNotebook() === $data }">
        <a href="javascript:void(0)" data-bind="text: name, click: $parent.selectedNotebook.bind(null, $data)"></a>
      </li>
    <!-- /ko -->
    <li>
      <a href="javascript:void(0)" data-bind="click: newNotebook"><i class="fa fa-plus" title="${ _('Add a new notebook') }"></i></a>
    </li>
  </ul>
</div>


<div class="container-fluid">
  <div class="row-fluid">
    <div class="span12">
        <div class="tab-content" data-bind="foreach: notebooks">
          <div class="tab-pane" data-bind="css: { active: $parent.selectedNotebook() === $data }, template: { name: 'notebook'}">
          </div>
        </div>
    </div>
  </div>
</div>


<script type="text/html" id="notebook">
  <div class="row-fluid">
    <div class="span2">
      <div class="assist">
        <a href="#" title="${_('Double click on a table name or field to insert it in the editor')}" rel="tooltip" data-placement="top" class="pull-right" style="margin:3px; margin-top:7px">
          <i class="fa fa-question-circle"></i>
        </a>
        <a id="refreshNavigator" href="#" title="${_('Manually refresh the table list')}" rel="tooltip" data-placement="top" class="pull-right" style="margin:3px; margin-top:7px">
          <i class="fa fa-refresh"></i>
        </a>
        <ul class="nav nav-list" style="border: none; padding: 0; background-color: #FFF">
          <li class="nav-header">${_('database')}</li>
        </ul>
        <!-- ko if: $root.assistContent && $root.assistContent().mainObjects().length > 0 -->
          <select data-bind="options: $root.assistContent().mainObjects, chosen: {}" class="input-medium" data-placeholder="${_('Choose a database...')}"></select>
          <input type="text" placeholder="${ _('Table name...') }" style="width:90%; margin-top: 20px"/>
          <div data-bind="visible: Object.keys($root.assistContent().firstLevelObjects()).length == 0">${_('The selected database has no tables.')}</div>
          <ul data-bind="visible: Object.keys($root.assistContent().firstLevelObjects()).length > 0, foreach: Object.keys($root.assistContent().firstLevelObjects())" class="unstyled assist-main">
            <li>
              <a href="javascript:void(0)" class="pull-right" style="padding-right:5px"><i class="fa fa-list" title="${'Preview Sample data'}" style="margin-left:5px"></i></a>
              <a href="javascript:void(0)" data-bind="click: loadAssistSecondLevel"><i class="fa fa-table"></i> <span data-bind="text: $data"></span></a>

              <div data-bind="visible: $root.assistContent().firstLevelObjects()[$data].loaded() && $root.assistContent().firstLevelObjects()[$data].open()">
                <ul data-bind="visible: $root.assistContent().firstLevelObjects()[$data].items().length > 0, foreach: $root.assistContent().firstLevelObjects()[$data].items()" class="unstyled">
                  <li><a data-bind="attr: {'title': secondLevelTitle($data)}" style="padding-left:10px" href="javascript:void(0)"><i class="fa fa-columns"></i> <span data-bind="html: truncateSecondLevel($data)"></span></a></li>
                </ul>
              </div>
            </li>
          </ul>
        <!-- /ko -->

        <div id="navigatorLoader" class="center" data-bind="visible: $root.assistContent().isLoading">
          <!--[if !IE]><!--><i class="fa fa-spinner fa-spin" style="font-size: 20px; color: #BBB"></i><!--<![endif]-->
          <!--[if IE]><img src="/static/art/spinner.gif"/><![endif]-->
        </div>
      </div>
    </div>
    <div class="span10">
      <div data-bind="css: {'row-fluid': true, 'row-container':true, 'is-editing': $root.isEditing},
        sortable: { template: 'snippet', data: snippets, isEnabled: $root.isEditing,
        options: {'handle': '.move-widget', 'opacity': 0.7, 'placeholder': 'row-highlight', 'greedy': true,
            'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});},
            'helper': function(event){lastWindowScrollPosition = $(window).scrollTop(); $('.card-body').slideUp('fast'); var _par = $('<div>');_par.addClass('card card-widget');var _title = $('<h2>');_title.addClass('card-heading simple');_title.text($(event.toElement).text());_title.appendTo(_par);_par.height(80);_par.width(180);return _par;}},
            dragged: function(widget){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}">
      </div>
      <div style="margin: 20px">
        <a href="javascript: void(0)" data-bind="click: newSnippet">
          <i class="fa fa-plus" title="${ _('Add') }"></i> ${ _('Add a new snippet') }
        </a>
        <select data-bind="options: availableSnippets, value: selectedSnippet">
        </select>
      </div>
    </div>
  </div>

</script>


<script type="text/html" id="snippet">
  <div class="row-fluid">
    <div data-bind="css: klass, attr: {'id': 'snippet_' + id()}">

      <h2 class="card-heading simple">

        <span data-bind="visible: $root.isEditing">
          <a href="javascript:void(0)" class="move-widget"><i class="fa fa-arrows"></i></a>
          <a href="javascript:void(0)" data-bind="click: compress, visible: size() > 1"><i class="fa fa-step-backward"></i></a>
          <a href="javascript:void(0)" data-bind="click: expand, visible: size() < 12"><i class="fa fa-step-forward"></i></a>
          &nbsp;
        </span>

        <!-- ko if: type() == 'text' -->
        <i class="fa fa-header snippet-icon"></i><sup style="color: #338bb8; margin-left: -2px">${ _('Text') }</sup>
        <!-- /ko -->

        <!-- ko if: type() == 'hive' -->
        <img src="/beeswax/static/art/icon_beeswax_48.png" class="snippet-icon">
        <!-- /ko -->

        <!-- ko if: type() == 'impala' -->
        <img src="/impala/static/art/icon_impala_48.png" class="snippet-icon">
        <!-- /ko -->

        <!-- ko if: type() == 'scala' -->
        <img src="/spark/static/art/icon_spark_48.png" class="snippet-icon"><sup style="color: #338bb8; margin-left: -2px">scala</sup>
        <!-- /ko -->

        <!-- ko if: type() == 'python' -->
        <img src="/spark/static/art/icon_spark_48.png" class="snippet-icon"><sup style="color: #338bb8; margin-left: -2px">python</sup>
        <!-- /ko -->

        <!-- ko if: type() == 'sql' -->
        <img src="/spark/static/art/icon_spark_48.png" class="snippet-icon"><sup style="color: #338bb8; margin-left: -2px">sql</sup>
        <!-- /ko -->

        <!-- ko if: type() == 'pig' -->
        <img src="/pig/static/art/icon_pig_48.png" class="snippet-icon">
        <!-- /ko -->


        <span data-bind="editable: id, editableOptions: {enabled: $root.isEditing(), placement: 'right'}"></span>
        <div class="inline pull-right">
          <strong class="muted" data-bind="text: status"></strong> &nbsp;
          <a href="javascript:void(0)" data-bind="visible: $root.isEditing, click: function(){ remove($parent, $data);}"><i class="fa fa-times"></i></a>
        </div>
      </h2>

      <div class="row-fluid">
        <div data-bind="css: editorKlass">
          <div data-bind="foreach: variables">
            <div>
              <span data-bind="text: name"></span>
              <input type="text" data-bind="value: value" />
            </div>
          </div>
          <textarea data-bind="value: statement_raw, codemirror: { 'id': id(), 'lineNumbers': true, 'matchBrackets': true, 'mode': editorMode(), 'enter': execute }"></textarea>
          <a href="javascript:void(0)" data-bind="click: execute" class="btn codeMirror-overlaybtn">${ _('Go!') }</a>
        </div>
      </div>

      <div data-bind="css: resultsKlass">
        <table class="table table-condensed">
          <thead>
            <tr data-bind="foreach: result.meta">
              <th data-bind="text: $data.name"></th>
            </tr>
          </thead>
          <tbody data-bind="foreach: result.data">
            <tr data-bind="foreach: $data">
              <td data-bind="text: $data"></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</script>


<link rel="stylesheet" href="/static/css/common_dashboard.css">
<link rel="stylesheet" href="/static/ext/css/codemirror.css">
<link rel="stylesheet" href="/spark/static/css/spark.css">
<link rel="stylesheet" href="/static/ext/css/bootstrap-editable.css">
<link rel="stylesheet" href="/static/ext/chosen/chosen.min.css">
<link rel="stylesheet" href="/static/ext/css/hue-charts.css">
<link rel="stylesheet" href="/static/ext/css/leaflet.css">
<link rel="stylesheet" href="/static/ext/css/nv.d3.min.css">
<link rel="stylesheet" href="/static/css/nv.d3.css">


<script src="/static/ext/js/codemirror-3.11.js"></script>
<script src="/static/js/codemirror-pig.js"></script>
<script src="/static/js/codemirror-hql.js"></script>
<script src="/static/js/codemirror-python.js"></script>
<script src="/static/js/codemirror-clike.js"></script>

<script src="/static/js/codemirror-show-hint.js"></script>

<script src="/static/js/codemirror-isql-hint.js"></script>
<script src="/static/js/codemirror-hql-hint.js"></script>
<script src="/static/js/codemirror-pig-hint.js"></script>
<script src="/static/js/codemirror-python-hint.js"></script>
<script src="/static/js/codemirror-clike-hint.js"></script>

<script src="/static/ext/js/markdown.min.js"></script>

<script src="/static/ext/js/bootstrap-editable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/jquery/plugins/jquery-ui-1.10.4.draggable-droppable-sortable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout-min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout.mapping-2.3.2.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout-sortable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/ko.editable.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/hue.utils.js"></script>
<script src="/static/js/ko.hue-bindings.js" type="text/javascript" charset="utf-8"></script>
<script src="/spark/static/js/assist.js" type="text/javascript" charset="utf-8"></script>
<script src="/spark/static/js/spark.vm.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/chosen/chosen.jquery.min.js" type="text/javascript" charset="utf-8"></script>


<script src="/static/js/hue.geo.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/hue.colors.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/ext/js/leaflet/leaflet.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/ext/js/d3.v3.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/topojson.v1.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/topo/world.topo.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/topo/usa.topo.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/js/nv.d3.datamaps.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.legend.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.multiBarWithBrushChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.lineWithBrushChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.growingDiscreteBar.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.growingDiscreteBarChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.growingMultiBar.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.growingMultiBarChart.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.growingPie.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/nv.d3.growingPieChart.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/js/ko.charts.js" type="text/javascript" charset="utf-8"></script>



<script type="text/javascript" charset="utf-8">

  var assist = new Assist({
    app: "beeswax",
    user: "${user}",
    failsQuietlyOn: [500], // error codes from beeswax/views.py - autocomplete
    baseURL: "${url('beeswax:api_autocomplete_databases')}"
  });

  ko.bindingHandlers.chosen = {
    init: function (element) {
      $(element).chosen({
        disable_search_threshold: 5,
        width: "100%"
      }).change(function(e, obj){
        viewModel.assistContent().selectedMainObject(obj.selected);
        loadAssistFirstLevel();
      });
    },
    update: function (element, valueAccessor, allBindings) {
      $(element).trigger('chosen:updated');
    }
  };


  ko.bindingHandlers.codemirror = {
    init: function (element, valueAccessor, allBindingsAccessor, vm) {

      $(document).on("error.autocomplete", function () {
        $(".CodeMirror-spinner").remove();
      });

      function hiveImpalaAutocomplete(cm, autocompleteSet, comingFromKeyEvent) {
        CodeMirror.fromDot = false;

        CodeMirror.onAutocomplete = function (data, from, to) {
          if (data.indexOf("(") > -1) {
            cm.setCursor({line: from.line, ch: from.ch + data.length - 1});
            hiveImpalaAutocomplete(cm, autocompleteSet);
          }
          if (CodeMirror.tableFieldMagic) {
            cm.replaceRange(" ", from, from);
            cm.setCursor(from);
            hiveImpalaAutocomplete(cm, autocompleteSet);
          }
        };

        function splitStatements(hql) {
          var statements = [];
          var current = "";
          var betweenQuotes = null;
          for (var i = 0, len = hql.length; i < len; i++) {
            var c = hql[i];
            current += c;
            if ($.inArray(c, ['"', "'"]) > -1) {
              if (betweenQuotes == c) {
                betweenQuotes = null;
              }
              else if (betweenQuotes == null) {
                betweenQuotes = c;
              }
            }
            else if (c == ";") {
              if (betweenQuotes == null) {
                statements.push(current);
                current = "";
              }
            }
          }

          if (current != "" && current != ";") {
            statements.push(current);
          }
          return statements;
        }

        function getStatementAtCursor(cm) {
          var _pos = cm.indexFromPos(cm.getCursor());
          var _statements = splitStatements(cm.getValue());
          var _cumulativePos = 0;
          var _statementAtCursor = "";
          var _relativePos = 0;
          for (var i = 0; i < _statements.length; i++) {
            if (_cumulativePos + _statements[i].length >= _pos && _statementAtCursor == "") {
              _statementAtCursor = _statements[i].split("\n").join(" ");
              _relativePos = _pos - _cumulativePos;
            }
            _cumulativePos += _statements[i].length;
          }
          return {
            statement: _statementAtCursor,
            relativeIndex: _relativePos
          };
        }

        function getTableAliases(textScanned) {
          var _aliases = {};
          var _val = textScanned.split("\n").join(" ");
          var _from = _val.toUpperCase().indexOf("FROM ");
          if (_from > -1) {
            var _match = _val.toUpperCase().substring(_from).match(/ ON| LIMIT| WHERE| GROUP| SORT| ORDER BY|;/);
            var _to = _val.length;
            if (_match) {
              _to = _match.index;
            }
            var _found = _val.substr(_from, _to).replace(/(\r\n|\n|\r)/gm, "").replace(/from/gi, "").replace(/join/gi, ",").split(",");
            for (var i = 0; i < _found.length; i++) {
              var _tablealias = $.trim(_found[i]).split(" ");
              if (_tablealias.length > 1) {
                _aliases[_tablealias[1]] = _tablealias[0];
              }
            }
          }
          return _aliases;
        }

        function tableHasAlias(tableName, textScanned) {
          var _aliases = getTableAliases(textScanned);
          for (var alias in _aliases) {
            if (_aliases[alias] == tableName) {
              return true;
            }
          }
          return false;
        }


        function fieldsAutocomplete(cm) {
          CodeMirror.possibleSoloField = true;
          try {
            var _statement = getStatementAtCursor(cm).statement;
            var _from = _statement.toUpperCase().indexOf("FROM");
            if (_from > -1) {
              var _match = _statement.toUpperCase().substring(_from).match(/ ON| LIMIT| WHERE| GROUP| SORT| ORDER BY|;/);
              var _to = _statement.length;
              if (_match) {
                _to = _match.index;
              }
              var _found = _statement.substr(_from, _to).replace(/(\r\n|\n|\r)/gm, "").replace(/from/gi, "").replace(/join/gi, ",").split(",");
            }

            var _foundTable = "";
            for (var i = 0; i < _found.length; i++) {
              if ($.trim(_found[i]) != "" && _foundTable == "") {
                _foundTable = $.trim(_found[i]).split(" ")[0];
              }
            }
            if (_foundTable != "") {
              if (tableHasAlias(_foundTable, _statement)) {
                CodeMirror.possibleSoloField = false;
                CodeMirror.showHint(cm, autocompleteSet);
              }
              else {
                assist.options.onDataReceived = function (data) {
                  if (data.columns) {
                    CodeMirror.catalogFields = data.columns.join(" ");
                    CodeMirror.showHint(cm, autocompleteSet);
                  }
                }

                if (_foundTable.indexOf("(") > -1) {
                  _foundTable = _foundTable.substr(_foundTable.indexOf("(") + 1);
                }

                var _aliases = getTableAliases(_statement);
                if (_aliases[_foundTable]) {
                  _foundTable = _aliases[_foundTable];
                }

                assist.getData(viewModel.assistContent().selectedMainObject() + "/" + _foundTable);
              }
            }
          }
          catch (e) {
          }
        }

        var pos = cm.cursorCoords();
        if ($(".CodeMirror-spinner").length == 0) {
          $("<i class='fa fa-spinner fa-spin CodeMirror-spinner'></i>").appendTo($("body"));
        }
        $(".CodeMirror-spinner").css("top", pos.top + "px").css("left", (pos.left - 4) + "px").show();

        if (comingFromKeyEvent) {

          var _statement = getStatementAtCursor(cm).statement;
          var _line = cm.getLine(cm.getCursor().line);
          var _partial = _line.substring(0, cm.getCursor().ch);
          var _table = _partial.substring(_partial.lastIndexOf(" ") + 1, _partial.length - 1);
          if (_statement.indexOf("FROM") > -1) {

            assist.options.onDataReceived = function (data) {
              if (data.columns) {
                var _cols = data.columns;
                for (var col in _cols) {
                  _cols[col] = "." + _cols[col];
                }
                CodeMirror.catalogFields = _cols.join(" ");
                CodeMirror.fromDot = true;
                CodeMirror.showHint(cm, autocompleteSet);
              }
            }

            if (_table.indexOf("(") > -1) {
              _table = _table.substr(_table.indexOf("(") + 1);
            }

            var _aliases = getTableAliases(_statement);
            if (_aliases[_table]) {
              _table = _aliases[_table];
            }

            assist.getData(viewModel.assistContent().selectedMainObject() + "/" + _table);

          }

        }
        else {
          assist.options.onDataReceived = function (data) {
            if (data.tables) {
              CodeMirror.catalogTables = data.tables.join(" ");
              var _statementAtCursor = getStatementAtCursor(cm);
              var _before = _statementAtCursor.statement.substr(0, _statementAtCursor.relativeIndex).replace(/;+$/, "");
              var _after = _statementAtCursor.statement.substr(_statementAtCursor.relativeIndex).replace(/;+$/, "");
              if ($.trim(_before).substr(-1) == ".") {
                var _statement = _statementAtCursor.statement;
                var _line = cm.getLine(cm.getCursor().line);
                var _partial = _line.substring(0, cm.getCursor().ch);
                var _table = _partial.substring(_partial.lastIndexOf(" ") + 1, _partial.length - 1);
                if (_statement.indexOf("FROM") > -1) {
                  assist.options.onDataReceived = function (data) {
                    if (data.columns) {
                      var _cols = data.columns;
                      for (var col in _cols) {
                        _cols[col] = "." + _cols[col];
                      }
                      CodeMirror.catalogFields = _cols.join(" ");
                      CodeMirror.showHint(cm, autocompleteSet);
                    }
                  }

                  if (_table.indexOf("(") > -1) {
                    _table = _table.substr(_table.indexOf("(") + 1);
                  }

                  var _aliases = getTableAliases(_statement);
                  if (_aliases[_table]) {
                    _table = _aliases[_table];
                  }

                  assist.getData(viewModel.assistContent().selectedMainObject() + "/" + _table);
                }
              }
              else {
                CodeMirror.possibleTable = false;
                CodeMirror.tableFieldMagic = false;
                if ((_before.toUpperCase().indexOf(" FROM ") > -1 || _before.toUpperCase().indexOf(" TABLE ") > -1 || _before.toUpperCase().indexOf(" STATS ") > -1) && _before.toUpperCase().indexOf(" ON ") == -1 && _before.toUpperCase().indexOf(" ORDER BY ") == -1 && _before.toUpperCase().indexOf(" WHERE ") == -1 ||
                    _before.toUpperCase().indexOf("REFRESH") > -1 || _before.toUpperCase().indexOf("METADATA") > -1 || _before.toUpperCase().indexOf("DESCRIBE") > -1) {
                  CodeMirror.possibleTable = true;
                }
                CodeMirror.possibleSoloField = false;
                if (_before.toUpperCase().indexOf("SELECT ") > -1 && _before.toUpperCase().indexOf(" FROM ") == -1 && !CodeMirror.fromDot) {
                  if (_after.toUpperCase().indexOf("FROM ") > -1 || $.trim(_before).substr(-1) == "(") {
                    fieldsAutocomplete(cm);
                  }
                  else {
                    CodeMirror.tableFieldMagic = true;
                    CodeMirror.showHint(cm, autocompleteSet);
                  }
                }
                else {
                  if ((_before.toUpperCase().indexOf("WHERE ") > -1 || _before.toUpperCase().indexOf("ORDER BY ") > -1) && !CodeMirror.fromDot && _before.toUpperCase().match(/ ON| LIMIT| GROUP| SORT/) == null) {
                    fieldsAutocomplete(cm);
                  }
                  else {
                    CodeMirror.showHint(cm, autocompleteSet);
                  }
                }
              }
            }
          }
          assist.getData(viewModel.assistContent().selectedMainObject());
        }
      }

      var options = $.extend(valueAccessor(), {
        extraKeys: {
          "Ctrl-Space": function (cm) {
            $(document.body).on("contextmenu", function (e) {
              e.preventDefault(); // prevents native menu on FF for Mac from being shown
            });
            switch (valueAccessor().mode) {
              case "text/x-pig":
                CodeMirror.availableVariables = [];
                CodeMirror.showHint(cm, CodeMirror.pigHint);
                break;
              case "text/x-python":
                CodeMirror.showHint(cm, CodeMirror.pythonHint);
                break;
              case "text/x-scala":
                CodeMirror.showHint(cm, CodeMirror.scalaHint);
                break;
              case "text/x-hiveql":
                hiveImpalaAutocomplete(cm, CodeMirror.hiveQLHint);
                break;
              case "text/x-impalaql":
                hiveImpalaAutocomplete(cm, CodeMirror.impalaSQLHint);
                break;
              default:
                break;
            }
          },
          "Ctrl-Enter": function () {
            valueAccessor().enter();
          }
        },
        onKeyEvent: function (cm, e) {
          switch (valueAccessor().mode) {
            case "text/x-hiveql":
              if (e.type == "keyup" && e.keyCode == 190) {
                hiveImpalaAutocomplete(cm, CodeMirror.hiveQLHint, true);
              }
              break;
            case "text/x-impalaql":
              if (e.type == "keyup" && e.keyCode == 190) {
                hiveImpalaAutocomplete(cm, CodeMirror.impalaSQLHint, true);
              }
              break;
            default:
              break;
          }
        }
      });
      var editor = CodeMirror.fromTextArea(element, options);

      element.editor = editor;
      $("#snippet_" + options.id).data("editor", editor);
      editor.setValue(allBindingsAccessor().value());
      window.setTimeout(function () {
        editor.refresh();
      }, 100);
      editor.setSize("100%", "100px");
      var wrapperElement = $(editor.getWrapperElement());

      editor.on("change", function () {
        allBindingsAccessor().value(editor.getValue());
      });

      ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
        wrapperElement.remove();
      });
    }
  };

  viewModel = new EditorViewModel(${ notebooks_json | n,unicode });
  viewModel.assistContent(assist);
  ko.applyBindings(viewModel);
  viewModel.init();

  function loadAssistSecondLevel(first){
    if (! viewModel.assistContent().firstLevelObjects()[first].loaded()){
      viewModel.assistContent().isLoading(true);
      assist.options.onDataReceived = function(data){
        if (data.columns){
          var _cols = data.extended_columns?data.extended_columns:data.columns;
          viewModel.assistContent().firstLevelObjects()[first].items(_cols);
          viewModel.assistContent().firstLevelObjects()[first].loaded(true);
        }
        viewModel.assistContent().isLoading(false);
      }
      assist.getData(viewModel.assistContent().selectedMainObject() + "/" + first);
    }
    viewModel.assistContent().firstLevelObjects()[first].open(! viewModel.assistContent().firstLevelObjects()[first].open());
    window.setTimeout(resizeAssist, 100);
  }

  function loadAssistFirstLevel() {
    assist.options.onDataReceived = function(data){
      if (data.tables){
        var _obj = {};
        data.tables.forEach(function(item){
          _obj[item] = {
            items: ko.observableArray([]),
            open: ko.observable(false),
            loaded: ko.observable(false)
          }
        });
        viewModel.assistContent().firstLevelObjects(_obj);
      }
      viewModel.assistContent().isLoading(false);
    }
    assist.getData(viewModel.assistContent().selectedMainObject());
  }

  function loadAssistMain() {
    assist.options.onDataReceived = function(data){
      if (data.databases){
        viewModel.assistContent().mainObjects(data.databases);
        if (viewModel.assistContent().mainObjects().length > 0 && ! viewModel.assistContent().selectedMainObject()){
          viewModel.assistContent().selectedMainObject(viewModel.assistContent().mainObjects()[0]);
          loadAssistFirstLevel();
        }
      }
    }
    assist.getData();
  }

  loadAssistMain();

  function needsTruncation(level) {
    return (level.name.length + level.type.length) > 20;
  }

  function secondLevelTitle(level) {
    var _title = "";

    if (level.comment && needsTruncation(level)) {
      _title = level.name + " (" + level.type + "): " + level.comment;
    } else if (needsTruncation(level)) {
      _title = level.name + " (" + level.type + ")";
    } else if (level.comment) {
      _title = level.comment;
    }
    return _title;
  }

  function truncateSecondLevel(level) {
    var escapeString = function (str) {
      return $("<span>").text(str).html().trim()
    }
    if (needsTruncation(level)) {
      return escapeString(level.name + " (" + level.type + ")").substr(0, 20) + "&hellip;";
    }
    return escapeString(level.name + " (" + level.type + ")");
  }

  function resizeAssist() {
    $(".assist").width($(".assist").parents(".span2").width());
    $(".assist").parents(".span2").height($(".assist").height() + 100);
    $(".assist-main").height($(window).height() - 230);
  }

  $(document).ready(function(){
    resizeAssist();
  });

</script>

${ commonfooter(messages) | n,unicode }

function RunOnElementLoad(element,type,name) {
 var myhref = location.hash;
 var splitR1;
 var splitR2;
 var modName;
 if( myhref != '' ) {
   splitR1 = myhref.split(type);
   splitR2 = splitR1[0].split("item_");
   if(typeof splitR2[1] =='undefined') {
     splitR2 = splitR2[0].split(element);
    }
   modName = "divid_" + splitR2[1] + type;
   showModule("name", modName);
   location.href=myhref;
 }
}
(function() {
    addEventListener('load', function() {
        var hierImageWraper, svg;
        var hierImageWraper = document.querySelector('.hier-image-wrapper');
        if (hierImageWraper) svg = hierImageWraper.querySelector('svg');
        if (!hierImageWraper || !svg) { return; }
        var svgHeight = parseInt(svg.getAttribute('height'));
        hierImageWraper.style.overflow = 'auto';
        hierImageWraper.style.border = '1px solid #7d7d7d';
        if ( svgHeight > 700 ) {
            hierImageWraper.style.maxHeight = '85vh';
        }
        var hierImageToggle = document.querySelector('.hier-image-toggle')
        hierImageToggle.addEventListener('click', centerHierDiagram)
    })
})();
var hierDiagramCentered = false;
function centerHierDiagram() {
    if (!hierDiagramCentered) {
        hierDiagramCentered = true;
    }
    var parent = document.querySelector('.hier-image-wrapper')
    var svg = parent.querySelector('svg')
    if (!parent || !svg) { return; }
    parentRect = parent.getBoundingClientRect();
    svgRect = svg.getBoundingClientRect();
    parent.scrollTop = svgRect.height / 2 - parentRect.height / 2;
    parent.scrollLeft = svgRect.width / 2 - parentRect.width / 2;
}

function getElementsByClass(searchClass) {
 var classElements = new Array();
 node = document;
 tag = '*';
 var els = node.getElementsByTagName(tag);
 var elsLen = els.length;
 var pattern = new RegExp("(^|\s)"+searchClass+"(\s|$)");
  for (i = 0, j = 0; i < elsLen; i++) {
    if ( pattern.test(els[i].className) ) {
       classElements[j] = els[i];
       j++;
    }
  }
  return classElements;
}
function hideElementsByClass(className){
	var elements = document.getElementsByClassName(className);
	for (var i = 0; i < elements.length; i++){
		elements[i].style.display = 'none';
	}
}

function showModule(classname, idname) {
 var moduleAttrDoc=idname + "_AttrDoc";
 hideAllClassNames(classname);
 document.getElementById(idname).style.display='block';
 document.getElementById(moduleAttrDoc).style.display='block';
}

function loadtbpage(testbenchname) {
  if(window['sessionStorage'] !== null && typeof window.sessionStorage != 'undefined') {
    sessionStorage.tbname = testbenchname;
    if (sessionStorage.getItem(sessionStorage.tbname) && document.getElementById(sessionStorage.getItem(sessionStorage.tbname))) {
      showDiv(sessionStorage.getItem(sessionStorage.tbname));
      return;
    }
  }
    var element;
    element = document.getElementById('topology');
    if(element) {
     showDiv('topology');
     return;
    }

    element = document.getElementById('testcases');
    if(element) {
     showDiv('testcases');
     return;
    }

    element = document.getElementById('env');
    if(element) {
     showDiv('env');
     return;
    }

    element = document.getElementById('hdl');
    if(element) {
     showDiv('hdl');
     return;
    }

    element = document.getElementById('readme');
    if(element) {
     showDiv('readme');
     return;
    }
}

function loadFilesPage() {
  var id;
  var element;
  for(i=0; i<sessionStorage.length; i++) {
    id = sessionStorage.key(i);
    element = document.getElementById(id);
    if(element) {
      if (element.className == "folder") {
          element.style.display = sessionStorage.getItem(id);
      }
      else {
          element.value = sessionStorage.getItem(id);
      }
    }
  }
}

function setTsModule(module_name) {
 window.location.href='modules.html#' + module_name;
 sessionStorage.itemname = module_name;
 showTsModule("mod")
}

function showTsModule(classname) {
 var moduleAttrDoc= sessionStorage.itemname + "_AttrDoc";
 hideAllClassNames(classname);
 document.getElementById(sessionStorage.itemname).style.display='block';
 document.getElementById(moduleAttrDoc).style.display='block';
}

function showDiv(idname) {
 hideAllDivs();
 var element;
 element = document.getElementById(idname);
 if(element) {
  element.style.display = 'block';
  if(window['sessionStorage'] !== null && typeof window.sessionStorage != 'undefined') {
    sessionStorage.setItem( sessionStorage.tbname, idname );
    }

 }

}

function hideAllClassNames(classname) {
 var tabs = getElementsByClass(classname);
 for(i=0; i<tabs.length; i++) {
  tabs[i].style.display = 'none';
 }
}

function hideAllDivs() {
 var element;
 element = document.getElementById('topology');
 if(element) {
  element.style.display = 'none';
 }

 element = document.getElementById('testcases');
 if(element) {
  element.style.display = 'none';
 }

 element = document.getElementById('env');
 if(element) {
  element.style.display = 'none';
 }

 element = document.getElementById('hdl');
 if(element) {
  element.style.display = 'none';
 }

 element = document.getElementById('readme');
 if(element) {
  element.style.display = 'none';
 }

}

function showAllClassNames(classname) {
 var tabs = getElementsByClass(classname);
 for(i=0; i<tabs.length; i++) {
  tabs[i].style.display = 'block';
 }
}

function toggleDiv(arg1,arg2) {
 if (document.getElementById(arg1).style.display == "block") {
   document.getElementById(arg1).style.display = "none";
   document.getElementById(arg2).value = "+";
   sessionStorage.setItem(arg1, "none");
   sessionStorage.setItem(arg2, "+");
 }
 else {
   document.getElementById(arg1).style.display = "block";
   document.getElementById(arg2).value = "-";
   sessionStorage.setItem(arg1, "block");
   sessionStorage.setItem(arg2, "-");
 }
}
function toggleExpandAll(classname, buttonname) {
  if(document.getElementById(buttonname).value == "Expand All") {
    showAllClassNames(classname);
    document.getElementById(buttonname).value="Collapse All";
    var tabs = getElementsByClass('cgp_buttons');
    for(i=0; i<tabs.length; i++) {
      tabs[i].value = '-';
    }
  }
  else {
    hideAllClassNames(classname);
    document.getElementById(buttonname).value="Expand All";
    var tabs = getElementsByClass('cgp_buttons');
    for(i=0; i<tabs.length; i++) {
      tabs[i].value = '+';
    }
  }
}

var sortClicksTable = {};
var oldRowsTable = {};

function sortTable(input, thTag, increasing=true) {
  if (!(input.id in sortClicksTable)) {
    sortClicksTable[input.id] = -1;
  }
  sortClicksTable[input.id]++;
  var table, rows, cols, oldCols, ths, thTages, cid, button, i, x, y;
  table = document.getElementById(input.id);
  rows = table.rows;
  button = document.getElementById("resetorder"+input.id);
  var ths = table.getElementsByTagName("TH");
  var thTags = Array.prototype.slice.call(ths);
  cid = -1;
  thTags.some(function(val, idx) {
    if (val == thTag) {
      cid = idx;
      return 1;
    }
  });
  if (cid == -1) {
    return;
  }
  var loader = ths[cid].getElementsByClassName("loader");
  loader[0].removeAttribute("hidden");
  setTimeout(function() {
    if (sortClicksTable[input.id] == 0) {
      if (!(input.id in oldRowsTable)) {
        oldRowsTable[input.id] = {};
      }
      for (i = 0; i < rows.length; i++) {
        oldRowsTable[input.id][i] = rows[i].cloneNode(true);
      }
    }
    mergeSort(rows, cid, 2, (rows.length - 1), increasing);
    loader[0].setAttribute("hidden", true);
    button.removeAttribute("disabled");
  }, 1);
}

function resetOrder(input, id) {
  var table, rows, button, i, j;
  table = document.getElementById(input.id);
  rows = table.rows;
  button = document.getElementById(id);
  var loader = button.getElementsByClassName("loader");
  loader[0].removeAttribute("hidden");
  setTimeout(function() {
    for (i = 2; i < rows.length; i++) {
      rows[i].replaceWith(oldRowsTable[input.id][i].cloneNode(true));
    }
    loader[0].setAttribute("hidden", true);
    button.setAttribute("disabled", true);
  }, 1);
}

function mergeSort(rows, cid, l, r, increasing) {
  if (l >= r)   return;
  var m = l + parseInt((r-l)/2);
  mergeSort(rows, cid, l, m, increasing);
  mergeSort(rows, cid, m+1, r, increasing);
  merge(rows, cid, l, m, r, increasing);
}

function merge(rows, cid, l, m, r, increasing) {
  var x, y;
  var n1 = m - l + 1;
  var n2 = r - m;
  var L = new Array(n1);
  var R = new Array(n2);
  for (var i = 0; i < n1; i++)
    L[i] = rows[l + i].cloneNode(true);
  for (var j = 0; j < n2; j++)
    R[j] = rows[m + 1 + j].cloneNode(true);
  var i = 0;
  var j = 0;
  var k = l;
  while (i < n1 && j < n2) {
    x = L[i].cells[cid].innerText.toLowerCase().replace(/\d+/g, n => +n+100000 );
    y = R[j].cells[cid].innerText.toLowerCase().replace(/\d+/g, n => +n+100000 );
    if (increasing) {
      if (x <= y) {
        rows[k].innerHTML = L[i].innerHTML;
        i++;
      }
      else {
        rows[k].innerHTML = R[j].innerHTML;
        j++;
      }
    }
    else {
      if (x > y) {
        rows[k].innerHTML = L[i].innerHTML;
        i++;
      }
      else {
        rows[k].innerHTML = R[j].innerHTML;
        j++;
      }
    }
    k++;
  }
  while (i < n1) {
    rows[k].innerHTML = L[i].innerHTML;
    i++;
    k++;
  }
  while (i < n1) {
    rows[k].innerHTML = R[j].innerHTML;
    j++;
    k++;
  }
}

function showClass(classname, id) {
  var tabs;
  if( document.getElementById(id).value == "-" ) {
    tabs = getElementsByClass(classname);
    for(i=0; i<tabs.length; i++) { 
      tabs[i].style.display = 'none';
    }
    document.getElementById(id).value = "+";
  }
  else {
    tabs = getElementsByClass(classname);
    for(i=0; i<tabs.length; i++) {
     tabs[i].style.display = 'block';
    }
    document.getElementById(id).value = "-";
  }
}
function makeTableHeadersInPageSticky() {
    var stickyHeaderTables = document.getElementsByClassName('stickyHeaderTable');
    for (var tableInd = 0; tableInd < stickyHeaderTables.length; tableInd++) {
        makeTableHeaderSticky(stickyHeaderTables[tableInd]);
    }
}
function getFirstVisibleRow(tbody) {
    var rows = tbody.rows,
        numRows = rows.length;
    for(var i=0; i<numRows; i++) {
        if(rows[i].style.display !== 'none') {
            return rows[i];
        }
    }
}
function makeTableHeaderSticky(table) {
    var tableHeader = table.tHead;
    if (!tableHeader)
        return;
    var headerFlag = false,
        tableHeaderHeight = tableHeader.getBoundingClientRect().height,
        headerSibling = table.tBodies[0].rows[0];
    document.addEventListener('scroll', onScrollListener);
    onScrollListener();
    table.removeAttribute('border');
    function onScrollListener(){
        var tableRect = table.getBoundingClientRect(),
            tableOffsetBottom = tableRect.top + tableRect.height;
        if (!headerFlag && (tableRect.top < 0 && tableOffsetBottom > tableHeaderHeight)) {
            setHeaderWidth();
            tableHeader.classList.add('fixedHeader');
            setHeaderWidth();
            headerFlag = true;
        } else if (headerFlag && (tableRect.top > tableHeaderHeight || tableOffsetBottom < tableHeaderHeight)) {
            tableHeader.classList.remove('fixedHeader');
            removeHeaderWidth()
            headerFlag = false;
        }
    }
    var resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        if (headerFlag){
            resizeTimeout();
            resizeTimer = setTimeout(resizeTimeout, 200);
        }
        function resizeTimeout() {
            setHeaderWidth();
            onScrollListener();
        };
    });
    function setHeaderWidth() {
        var headerCols = tableHeader.rows[0].cells,
            siblingCols = headerSibling.cells,
            firstVisibleRow = getFirstVisibleRow(table.tBodies[0]).cells;
        for (var i = 0; i < siblingCols.length; i++)
            headerCols[i].style.width = siblingCols[i].style.width = window.getComputedStyle(firstVisibleRow[i]).width;
        var inter = setInterval(function() {
            var widthEqual = true;
            for (var i = 0; i < siblingCols.length; i++) {
                var computedWidth = window.getComputedStyle(firstVisibleRow[i]).width;
                if(siblingCols[i].style.width !== computedWidth || headerCols[i].style.width !== computedWidth){
                    headerCols[i].style.width = siblingCols[i].style.width = computedWidth;
                    widthEqual = false;
                }
            }
            if(widthEqual)
                clearInterval(inter);
        }, 100);
        tableHeader.style.width = window.getComputedStyle(table.tBodies[0]).width;
    }
    function removeHeaderWidth() {
        var headerCols = tableHeader.rows[0].cells;
        for (var i = 0; i < headerCols.length; i++)
            headerCols[i].style.removeProperty('width');
    }
}

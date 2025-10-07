function getCrntPagename() {
    var crnt_page_name = "", crnt_page_path="";
    crnt_page_path = window.location.pathname;
    if(crnt_page_path)
            crnt_page_name = crnt_page_path.split("/").pop();
    return crnt_page_name;
}
var Tables =new Array();
var ref_row='';
var defaultValues;
var pcbutton=new Array();
var col_visible_always=0;
var more_width_cols=new Array();
var defHiddenCols = {};
function createSelectFilter(table, col_options_list, col_num) {
    var crnt_page_name = getCrntPagename();
    var sel_ele = document.createElement('select');
    sel_ele.id = 'flt'+col_num+'_'+table.id;
    sel_ele.style.width = '100%';
    sel_ele.className = 'flt';
    var currOpt = new Option('SELECT ALL','',false,false);
    sel_ele.options[0] = currOpt;
    var OptArray = col_options_list['col_'+col_num].slice();
    OptArray.sort();
    for(var k = 0; k < col_options_list['col_'+col_num].length ; k++){
        var currOpt = new Option(OptArray[k], OptArray[k], false, false);
        sel_ele.options[k + 1] = currOpt;
        if(defaultValues['col_'+col_num]){
            var def_col_value= defaultValues['col_'+col_num].replace(/^[ ]+|[ ]+$/g,'');
            if( def_col_value ==  OptArray[k])
                sel_ele.selectedIndex=k+1;
        }
        else if(defaultValues['GroupName']){
            var def_col_value= defaultValues['GroupName'].replace(/^[ ]+|[ ]+$/g,'');
            if( def_col_value ==  OptArray[k])
                sel_ele.selectedIndex=k+1;
        }
        else if(defaultValues['SubGroupName']){
            var def_col_value= defaultValues['SubGroupName'].replace(/^[ ]+|[ ]+$/g,'');
            if( def_col_value ==  OptArray[k])
                sel_ele.selectedIndex=k+1;
        }
    }
    sel_ele.onchange = function() {
        Filter(table, sel_ele.id);
    }
    return sel_ele;
}
/* START OF MultiSelectFilter CLASS */
function MultiSelectFilter(id) {
    this.id = id;
    this.setupElements();
    this.setupEvents();
    this.selectionChangeCallbacks = [];
    this.checkboxes = [];
}
MultiSelectFilter.prototype.addMenuItem = function(itemName, isCheckable, defaultChecked) {
    // Default argument values
    if (isCheckable === undefined) {
        isCheckable = true;
        defaultChecked = false;
    }
    if ( defaultChecked === undefined ) {
        defaultChecked = false
    }
    var menuItemElement = document.createElement('li');
    var menuItemLabel = document.createElement('label');
    menuItemElement.appendChild(menuItemLabel);
    var menuItemCheckbox = null;
    if (isCheckable) {
        menuItemCheckbox = document.createElement('input');
        menuItemCheckbox.type = 'checkbox';
        menuItemCheckbox.checked = defaultChecked;
        menuItemLabel.appendChild(menuItemCheckbox);
        this.checkboxes.push(menuItemCheckbox);
        menuItemCheckbox.addEventListener('change', onSelect.bind(this));
    } else {
        menuItemElement.addEventListener('click', onSelect.bind(this));
    }
    var menuItemName = document.createTextNode(itemName);
    menuItemLabel.appendChild(menuItemName);
    if ( !this.filterMenuList.querySelector('li') ) {
        this.setCurSelectionText(itemName);
    }
    this.filterMenuList.appendChild(menuItemElement);
    function onSelect(event) {
        var itemType = isCheckable ? 'checkbox' : 'button';
        this.menuItemSelected(itemName, itemType, menuItemElement);
    }
    return menuItemElement;
}
MultiSelectFilter.prototype.menuItemSelected = function(name, type, element) {
    var selectedItems = [];
    if ( type === 'button' ) {
        selectedItems.push(name);
    } else {
        for ( var i = 0; i < this.checkboxes.length; i++ ) {
            var itemLabel = this.checkboxes[i].parentElement;
            var itemName = itemLabel.textContent.trim();
            if ( this.checkboxes[i].checked ) {
                selectedItems.push(itemName);
            }
        }
    }
    if ( selectedItems.length != 0 ) {
        var selectedItemsString = selectedItems.join(', \n');
    } else {
        var firstItem = this.filterMenuList.querySelector('li');
        selectedItemsString = firstItem.textContent.trim();
    }
    this.setCurSelectionText(selectedItemsString);
}
MultiSelectFilter.prototype.removeCheckboxItems = function () {
    for ( var i = 0; i < this.checkboxes.length; i++ ) {
        // Get checkbox -> label -> li
        var listItem = this.checkboxes[i].parentElement.parentElement;
        listItem.parentElement.removeChild(listItem);
    }
    this.checkboxes = [];
}
MultiSelectFilter.prototype.clearSelection = function () {
    for (var i = 0; i < this.checkboxes.length; i++) {
        this.checkboxes[i].checked = false;
    }
    var firstItem = this.filterMenuList.querySelector('li');
    selectedItemsString = firstItem.textContent.trim();
    this.setCurSelectionText(selectedItemsString);
}
MultiSelectFilter.prototype.open = function() {
    // Save selection state on open
    this._stateOnOpen = this.getSelectionState();
    this.filterMenuList.style.display = 'inline-block';
    var viewPortHeight = document.documentElement.clientHeight;
    var elementRect = this.filterMenuList.getBoundingClientRect();
    if ( elementRect.bottom > viewPortHeight ) {
        this.filterMenuList.style.height = (viewPortHeight - elementRect.top - 10) + 'px';
        this.filterMenuList.style.overflowY = 'scroll';
    }
}
MultiSelectFilter.prototype.isOpen = function() {
    return ( this.filterMenuList.style.display === 'inline-block' );
}
MultiSelectFilter.prototype.close = function() {
    if ( this.isClosed() ) {
        return;
    }
    this.filterMenuList.style.display = 'none';
    this.filterMenuList.style.removeProperty('height');
    this.filterMenuList.style.removeProperty('overflow-y');
    // If selection state has change, fire selection change event
    this._stateOnClose = this.getSelectionState();
    if ( this._stateOnOpen !== this._stateOnClose ) {
        this.fireSelectionChange();
    }
}
MultiSelectFilter.prototype.isClosed = function() {
    return ( this.filterMenuList.style.display === 'none' );
}
MultiSelectFilter.prototype.setCurSelectionText = function(text) {
    this.selectionDisplay.innerText = text;
    this.selectMenuOverlay.setAttribute('title', text);
}
MultiSelectFilter.prototype.clearCurSelectionText = function() {
    this.selectionDisplay.innerText = '';
}
MultiSelectFilter.prototype.setupElements = function() {
    // Top level wrapper
    this.filterMenuWrapper = document.createElement('div');
    this.filterMenuWrapper.id = this.id;
    this.filterMenuWrapper.className = 'filterMenuWrapper';
    // <div> wrapper around select element
    var selWrapper = document.createElement('div');
    selWrapper.className = 'filter_select_wrapper';
    this.filterMenuWrapper.appendChild(selWrapper);
    // Dummy <select> element
    this.selectElement = document.createElement('select');
    this.selectElement.className = 'dummy_filter_select';
    selWrapper.appendChild(this.selectElement);
    // Dummy <option> element
    this.selectionDisplay = document.createElement('option');
    this.selectionDisplay.innerText = '';
    this.selectElement.appendChild(this.selectionDisplay);
    // Overlay <div> element to hide default menu of <select> element
    this.selectMenuOverlay = document.createElement('div');
    this.selectMenuOverlay.className = 'default_options_hide';
    selWrapper.appendChild(this.selectMenuOverlay);
    // Filter menu list <ul>
    this.filterMenuList = document.createElement('ul');
    this.filterMenuList.className = 'filter_menu_items';
    this.filterMenuList.style.display = 'none';
    this.filterMenuWrapper.appendChild(this.filterMenuList);
}
MultiSelectFilter.prototype.getSelectionState = function() {
    var selectionState = '';
    // checkboxList = this.filterMenuList.querySelectorAll('input[type=checkbox]');
    for (var i = 0; i < this.checkboxes.length; i++) {
        selectionState += this.checkboxes[i].checked ? '1' : '0';
    }
    return selectionState;
}
MultiSelectFilter.prototype.getSelectedItemNames = function() {
    var selectedItems = [];
    var labels = this.filterMenuWrapper.querySelectorAll('label');
    for (var i = 0; i < labels.length; i++) {
        var checkbox = labels[i].querySelector('input[type=checkbox]');
        if (checkbox && checkbox.checked) {
            selectedItems.push(labels[i].textContent.trim());
        }
    }
    return selectedItems;
}
MultiSelectFilter.prototype.setupEvents = function() {
    // Open menu when select element is clicked
    function onMenuClick(event) {
        this.isClosed() ? this.open() : this.close();
    }
    // Close menu if clicked outside
    function onWindowClick(event) {
        if ( !this.isClosed() &&
             this.filterMenuWrapper !== event.target &&
             !this.filterMenuWrapper.contains(event.target)
        ) {
            this.close();
        }
    }
    this.selectMenuOverlay.addEventListener('click', onMenuClick.bind(this));
    window.addEventListener('click', onWindowClick.bind(this));
    window.addEventListener('scroll', this.close.bind(this));
}
MultiSelectFilter.prototype.onSelectionChange = function(callbackFunction) {
    this.selectionChangeCallbacks.push(callbackFunction);
}
MultiSelectFilter.prototype.fireSelectionChange = function() {
    for (var i = 0; i < this.selectionChangeCallbacks.length; i++) {
        this.selectionChangeCallbacks[i]();
    }
}
/* END OF MultiSelectFilter CLASS */
function createMultiSelectFilter(table, colOptionsMap, colNum) {
    var crnt_page_name = getCrntPagename();
    var filterMenuId = 'flt' + colNum + '_' + table.id;
    var selectFilter = new MultiSelectFilter(filterMenuId);
    selectAllMenuItemElement = selectFilter.addMenuItem('SELECT ALL', false);
    var colOptions = colOptionsMap['col_'+colNum].slice();
    colOptions.sort();
    for(var optionIndex = 0; optionIndex < colOptions.length ; optionIndex++){
        var defaultChecked = false;
        var colOption = colOptions[optionIndex].trim();
        if(defaultValues['col_'+colNum]){
            var defColVal = defaultValues['col_'+colNum].trim();
            if( defColVal == colOption)
                defaultChecked = true;
        }
        else if(defaultValues['GroupName']){
            var defColVal = defaultValues['GroupName'].trim();
            if( defColVal == colOption)
                defaultChecked = true;
        }
        else if(defaultValues['SubGroupName']){
            var defColVal = defaultValues['SubGroupName'].trim();
            if( defColVal == colOption)
                defaultChecked = true;
        }
        selectFilter.addMenuItem(colOption, true, defaultChecked);
    }
    selectFilter.onSelectionChange(function() {
        Filter(table, filterMenuId);
    });
    // Action when 'SELECT ALL' option is clicked
    selectAllMenuItemElement.addEventListener('click', function() {
        selectFilter.clearSelection();
        selectFilter.close();
        Filter(table, filterMenuId);
    });
    return selectFilter
}
function setFilter(id, ref_row, tobj, filter_col_vals){
    var input = document.getElementById(id); var index;
    var farray;
    var ob ={};
    // Contains references to all multi-select filter objects for each column in this table
    input.multiSelectFilters = [];
    if(input!=null && input.nodeName.toLowerCase()=='table'){
        window.ref_row = ref_row;
        input.num_cols=getNumCols(input,ref_row);
        input.table_obj=tobj;
        index=tobj['row_index'];
        if(typeof tobj['col_visible_always']!='undefined')
            col_visible_always=tobj['col_visible_always'];
        if(typeof tobj['more_width_cols']!='undefined')
            more_width_cols=tobj['more_width_cols'];
        farray = filter_col_vals;
        getDefaultFilterValues();
        Tables.push(id);
        ob.clicked=0;
        ob.selected_checkclass='';
        ob.group='';
        pcbutton[id]=ob;
        var gridrow=input.insertRow(0);
        gridrow.className='gridrow';
        for(var i=0;i<input.num_cols;i++){
            var isMultiSelectFilterCol = true;
            if ( tobj['col_'+i+'_type'] === 'singleselect' ) {
                isMultiSelectFilterCol = false;
            }
            var gridcell=gridrow.insertCell(i);
            gridcell.style.width = 'auto';
             if(tobj['col_'+i]=='hidden_col' || tobj['col_'+i]=='hidden_fltr')
                 gridcell.style.display = 'none';
            if(tobj['col_'+i]=='active_fltr' || tobj['col_'+i]=='pc_ref_fltr'||tobj['col_'+i]=='hidden_fltr'){
                if (defaultValues['col_'+i]) {
                    var def_col_no = i;
                }
                var filterElement = null;
                // Create single selection filter/multi selection filter based on the fitler type provided for column.
                if (isMultiSelectFilterCol) {
                    var filterMenu = createMultiSelectFilter(input, farray, i);
                    filterElement = filterMenu.filterMenuWrapper;
                    input.multiSelectFilters[i] = filterMenu;
                } else {
                    filterElement = createSelectFilter(input, farray, i);
                }
                gridcell.appendChild(filterElement);
            }
        }
    }
    if(defaultValues['col_'+def_col_no] || defaultValues['GroupName'] || defaultValues['SubGroupName']){
        Filter(input);
    }
}
function getChildElem(obj){
	if(obj.nodeType == 1){
		for (var i=0; i<obj.childNodes.length; i++){
			var child=obj.childNodes[i];
			if(child.nodeType == 3) obj.removeChild(child);
		}
		return obj;
	}
}
function getNumCols(input,row){
	var tr;
	if(row==undefined) tr= input.getElementsByTagName("tr")[0];
	else tr= input.getElementsByTagName("tr")[row];
	return getChildElem(tr).childNodes.length;
}
function getCellText(cell){
    var cell_data="";
 if(cell){
            var childs=cell.childNodes;
            for(var i=0;i<childs.length;i++){
                if(childs[i].nodeType ==3) cell_data+=childs[i].data;
                else if(childs[i].className.match(/\bdesc\b/)){
                    continue;
                }
                else{
                    cell_data+=getCellText(childs[i]);
                }
            }
    }return cell_data;
}
function getCellTextWithLineBreaks(cell){
    var cell_data="";
 if(cell){
            var childs=cell.childNodes;
            for(var i=0;i<childs.length;i++){
                if(childs[i].nodeType ==3) cell_data+=childs[i].data;
                else if(childs[i].className.match(/\bdesc\b/)){
                    continue;
                }
                else{
                    if(childs[i] && childs[i].nodeName=="BR")
                      cell_data+="<br>";
                    else if(childs[i] && childs[i].nodeName=="WBR")
                      cell_data+="<wbr>";
                    else
                      cell_data+=getCellTextWithLineBreaks(childs[i]);
                }
            }
    }return cell_data;
}
function PopulateOptions(input,farray){
	var row=input.getElementsByTagName("tr");
	var tobj=input.table_obj;
	for (var k=ref_row;k<row.length;k++){
	if(row[k].style.display!="none"){
		var cell=getChildElem(row[k]).childNodes;
		if (input.num_cols == cell.length){
			updateFilterArrays(farray,tobj,cell);
		}
	}
	}
}
function updateFilterArrays(farray,tobj,cell){
    var crnt_page_name = getCrntPagename();
	var index=tobj["row_index"];
	var w,i,isMatched;
	for(i=0;i<cell.length;i++){
		if(tobj["col_"+i]=="active_fltr"||tobj["col_"+i]=="pc_ref_fltr"||tobj["col_"+i]=="hidden_fltr"){
			isMatched=false;
			var cell_data=getCellText(cell[index+i]).replace(/^[ ]+|[ ]+$/g,'');
			if(typeof farray["col_"+i]=="undefined"){
				farray["col_"+i]=[];
                            if(cell_data != ""){
                              if(tobj["col_"+i]=="pc_ref_fltr"){
                                    var speclist= getSpecListFromCell(cell[index+i]);
                                    var j=0;
                                    for(j=0;j<speclist.length;j++){
                                          if(speclist[j] && speclist[j]!=""){
                                                farray["col_"+i].push(speclist[j]);
                                          }
                                    }
                              }
                              else
                                    farray["col_"+i].push(cell_data);
                            }
				else
					farray["col_"+i].push("Unspecified");
			}
			else{
				for(w=0;w<farray["col_"+i].length;w++){
					if (cell_data==farray["col_"+i][w]){isMatched=true; break;}
				}
				if(!isMatched){
                                    if(cell_data != ""){
                                            if(tobj["col_"+i]=="pc_ref_fltr"){
                                                    var speclist= getSpecListFromCell(cell[index+i]);
                                                    var j=0,found_spc=0;
                                                    for(j=0;j<speclist.length;j++){
                                                            found_spc=0;
                                                            if(speclist[j] && speclist[j]!=""){
                                                                    for(w=0;w<farray["col_"+i].length;w++){
                                                                            if (speclist[j]==farray["col_"+i][w]){found_spc=1; break;}
                                                                    }
                                                                    if(!found_spc) farray["col_"+i].push(speclist[j]);
                                                            }
                                                    }
                                            }
                                            else
                                                    farray["col_"+i].push(cell_data);
                                    }
					else{
						if(farray["col_"+i].indexOf("Unspecified")==-1)
							farray["col_"+i].push("Unspecified");
					}
				}
			}
		}
	}
}
function clearFilters(input,id){
    pcbutton[input.id].clicked=0;
    pcbutton[input.id].selected_checkclass='';
    pcbutton[input.id].group='';
    var tr= input.getElementsByTagName('tr')[0];
    for(var i=0;i<tr.childNodes.length;i++){
        if(defaultValues['col_'+i] || defaultValues['GroupName'] || defaultValues['SubGroupName']){
            window.location=window.location.href.split('?')[0];
            break;
        }
        if(input.table_obj['col_'+i]=='active_fltr'||input.table_obj['col_'+i]=='pc_ref_fltr'||input.table_obj['col_'+i]=='hidden_fltr') {
            if (input.multiSelectFilters[i]) {
                input.multiSelectFilters[i].clearSelection();
            } else {
                tr.childNodes[i].firstChild.value='';
            }
        }
    }
    document.getElementById('results'+input.id).style.display='none';
    Filter(input);
}
function checkOptionInMultiItemList(cell_data, option_list){
    var cell_val_list = cell_data.split('&');
    var i = 0;
    for( i = 0; i < cell_val_list.length; i++){
            if(option_list.indexOf(cell_val_list[i]) !== -1){
                    return true;
            }
    }
    return false;
}
function getDefaultFilterValues(){
	(window.onpopstate = function () {
		var match,
            pl     = /\+/g,  // Regex for replacing addition symbol with a space
            search = /([^&=]+)=?([^&]*)/g,
            decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
            query  = window.location.search.substring(1);
            defaultValues = {};
            while (match = search.exec(query))
                    defaultValues[decode(match[1])] = decode(match[2]);
	})();
}
function Filter(input,sid){
    var crnt_page_name = getCrntPagename();
    var id = input.id;
    // Contains array of selected items for each column
    var selectedMenuOptions = new Array();
    var farray={};
    var noFilterSelected=true;
    var tr=input.rows;
    var tobj= input.table_obj;
    var child=tr[0].cells;
    // Populate selectedMenuOptions. It contains array of selected items for each column
    for(var i=0; i<child.length;i++){
        var selectedOptionsInCol = [];
        if(tobj['col_'+i]=='active_fltr'|| tobj['col_'+i]=='pc_ref_fltr'||tobj['col_'+i]=='hidden_fltr') {
            if (input.multiSelectFilters[i]) {
                selectedOptionsInCol = input.multiSelectFilters[i].getSelectedItemNames();
            } else {
                var selectionValue = child[i].firstChild.value.trim();
                if ( selectionValue ) {
                    selectedOptionsInCol.push(selectionValue);
                }
            }
        }
        selectedMenuOptions.push(selectedOptionsInCol);
    }
    for(var i = ref_row+1; i < tr.length; i++){
        if(tr[i].style.display=='none') tr[i].style.display='';
        var row=tr[i].cells;
        var row_length=row.length;
        var occurrence =new Array();
        var isRowValid=true;
        if(input.num_cols == row_length){
            for (var j=0;j<row_length;j++){
                // If there are no selected items in this column(select all), continue
                if (!selectedMenuOptions[j].length) {
                    continue;
                }
                noFilterSelected = false;
                // Get cell value of current row
                var descElements = row[j].getElementsByClassName('desc');
                if (descElements && descElements.length)
                    descElements[0].parentElement.removeChild(descElements[0]);
                var cell_data = row[j].textContent.trim();
                if(input.table_obj['col_'+j]=='active_fltr' || input.table_obj['col_'+j]=='pc_ref_fltr'||input.table_obj['col_'+j]=='hidden_fltr' ) {
                    if (selectedMenuOptions[j].indexOf(cell_data) !== -1) {
                        occurrence[j] = true;
                    } else if (cell_data === '' && selectedMenuOptions[j].indexOf('Unspecified') !== -1) {
                        occurrence[j] = true;
                    }
                    else if(input.table_obj['col_'+j]=='pc_ref_fltr'){
                        var speclist= getSpecListFromCell(row[j]);
                        var k=0;
                        for(k=0;k<speclist.length;k++){
                            if (selectedMenuOptions[j].indexOf(speclist[k]) !== -1) {
                                  occurrence[j] = true;break;
                            }
                        }
                    }
                }
                if(!occurrence[j]) isRowValid=false;
            }
            if(pcbutton[id].clicked==1){
                if(noFilterSelected)
                    noFilterSelected=false;
                if(getCellText(row[row_length-1])!=pcbutton[id].selected_checkclass ||
                    getCellText(row[0])!=pcbutton[id].group){
                    isRowValid=false;
                }
            }
            if(isRowValid){
                tr[i].style.display='';
                updateFilterArrays(farray,tobj,row);
            }
            else{
                tr[i].style.display='none';
            }
        }
    }
    if(noFilterSelected)
        document.getElementById('reset'+id).disabled='disabled';
    else
        document.getElementById('reset'+id).disabled='';
    update_dropdown(farray, input, sid, selectedMenuOptions);
}
function update_dropdown(farray, inputTable, filteredColId, selectedMenuOptions){
    var id = inputTable.id;
    var tobj = inputTable.table_obj;
    var col_count = getNumCols(inputTable);
    for(var i=0;i<col_count;i++){
        var current_fltr_id = 'flt'+i+'_'+id;
        // If this is not a filter enabled column, skip
        if(tobj['col_'+i] != 'active_fltr' && tobj['col_'+i] != 'pc_ref_fltr'&&tobj['col_'+i] != 'hidden_fltr') {
            continue;
        }
        var selectedMenuOption = selectedMenuOptions[i] || [];
        // Skip updating menu of column which initiated the update if there are one or more selected items
        if (current_fltr_id === filteredColId && selectedMenuOption.length) {
            continue;
        }
        var OptArray = farray['col_'+i].slice();
        OptArray.sort();
        // If this is not a multi select filter
        if (!inputTable.multiSelectFilters[i]) {
            var sel_ele=document.getElementById(current_fltr_id);
            var length = sel_ele.options.length;
            for (var j = length; j >=1; j--) {
                sel_ele.remove(j);
            }
            for(var k=0;k<OptArray.length;k++){
                sel_ele.options[k+1] = new Option(OptArray[k],OptArray[k],false,false);
                if( sel_ele.options[k+1].value === selectedMenuOption[0] ){
                    sel_ele.options[k+1].selected = true;
                }
            }
        // If this is a multi select filter
        } else {
            inputTable.multiSelectFilters[i].removeCheckboxItems();
            for(var k = 0; k < OptArray.length; k++){
                var defaultChecked = false;
                if ( selectedMenuOption.indexOf(OptArray[k]) !== -1 ) {
                    defaultChecked = true;
                }
                inputTable.multiSelectFilters[i].addMenuItem(OptArray[k], true, defaultChecked);
            }
        }
    }
}
function getSpecListFromCell(cell) {
    var ref_txt=getCellTextWithLineBreaks(cell);
    var crnt_spec="";
    var speclist=[];
    if(ref_txt.indexOf("<br>")!=-1 || ref_txt.indexOf("<wbr>,")!=-1){ 
     var ref_txt_list = ref_txt.split("<br>");
     var i=0,j=0;
     for(i=0;i<ref_txt_list.length;i++){
           if(ref_txt_list[i].indexOf(":")!=-1){
                 var crnt_spec_list=ref_txt_list[i].split(":")[0].trim().split("<wbr>,");
                 for(j=0;j<crnt_spec_list.length;j++){
                       crnt_spec=crnt_spec_list[j].trim();
                       speclist.push(crnt_spec);
                 }
           }
     }
    }
    else{
     if(ref_txt.indexOf(":")!=-1){
           crnt_spec=ref_txt.split(":")[0].trim();
           speclist.push(crnt_spec);
     }
    }
    return speclist;
}
function checkClassSpecific(checkClass,groupName){
    var crnt_page_name = getCrntPagename();
	var farray={};
	var id=document.getElementById(checkClass).value;
	var input=document.getElementById(id);
	pcbutton[id].clicked=1;
	pcbutton[id].selected_checkclass=checkClass;
	pcbutton[id].group=groupName;
    document.getElementById("reset"+id).disabled="";
	var tr=document.getElementById(id).getElementsByTagName("tr");
	var headers=getChildElem(tr[1]).childNodes;
	var index=input.table_obj["row_index"];
	for(var i=0;i<headers.length;i++){
		var header_data=getCellText(headers[i]).replace(/^[ ]+|[ ]+$/g,'');
		if(header_data=="Group") {index=i;break;}
	}
	for(var i=ref_row+1;i<tr.length;i++){
		if(tr[i].style.display=="none") tr[i].style.display="";
		var row=getChildElem(tr[i]).childNodes;
		var isRowValid=true;
		var cell_data=getCellText(row[index]);
		if(cell_data == groupName) isRowValid=true;
		else isRowValid=false;
		var row_length=row.length-1;
		cell_data=getCellText(row[row_length]);
		if(isRowValid && cell_data == checkClass){ 
			tr[i].style.display="";
			updateFilterArrays(farray,input.table_obj,row);
		}
		else tr[i].style.display="none";
	}
    document.getElementById("results"+id).innerHTML="Protocol Checks belonging to "+checkClass+" - Group "+groupName;
    document.getElementById("results"+id).style.display="";
	var searchOpt=new Array();
	update_dropdown(farray, input, "",searchOpt);
}
function showCheckboxes(flag,product_name) {
	var checkboxes = document.getElementById('checkboxes_'+product_name);
	if (flag==1) {
		if (checkboxes.style.display!="block") {
			checkboxes.style.display = "block";
		}
		else {
			checkboxes.style.display = "none";
		}
	}
	else if (flag==-1) {
		if (checkboxes.style.display!="none") {
			checkboxes.style.display = "none";
		}
	}
}
function show_hide_autohide(event,product_name){
	var popElement = document.getElementsByClassName("multiselect");
	var isClickInside=false;
	if(popElement.length!=0){
		for(var j=0;j<popElement.length;j++)
			if(popElement[j].contains(event.target)){isClickInside=true;break;}
		if(!isClickInside){
			showCheckboxes(-1,product_name);
		}
	}
}
function show_hide_refresh(event,product_name) {
	var historyTraversal=event.persisted||(typeof window.performance != "undefined" && window.performance.navigation.type === 2 );
	var flag=navigator.userAgent.search("Firefox");
	if ( !historyTraversal ||( historyTraversal && flag==-1)) {
		var c = document.getElementById('checkboxes_'+product_name);
		if(c!=null){
			var x=c.innerHTML;
			c.innerHTML = x;
		}
	}
}
function show_hide(col_name,product_name) {
	var stl,dis,check,col_no,header_data;
	var checkboxes = document.getElementById('checkboxes_'+product_name);
	var c=checkboxes.getElementsByTagName("input");
	var cl=checkboxes.getElementsByTagName("label");
	var checkboxLen = c.length;
	var tbl  = document.getElementById('table_'+product_name);
	var rows = tbl.getElementsByTagName("tr");
	var rowsLen = rows.length;
    var fltr_row_exists = tbl.getElementsByClassName('gridrow').length;
	var header_row_index = (fltr_row_exists ? 1 : 0);
	var row_headers = rows[header_row_index].getElementsByTagName('th');
	var colLen = row_headers.length;
	if(col_name=="All")
		col_no=-1;
	else{
		var headers=getChildElem(rows[header_row_index]).childNodes;
		for(var i=0;i<headers.length;i++){
			header_data=getCellText(headers[i]).replace(/^[ ]+|[ ]+$/g,'').replace(' ▲▼','');
			if(col_name==header_data){
				col_no=i;
				break;
			}
		}
	}
	if(col_no>-2){
		if(c[col_no+1].checked){
			stl = "table-cell";
			check=true;
		}
		else{
			stl = "none";
			check=false;
		}
    }
    // Default state of all columns
	var defColVisibility = [];
	var hiddenCols = defHiddenCols[product_name];
	var next = 0;
	for(var col_index=0;col_index<colLen;col_index++){
		if (cl[col_index+1].innerText.trim() === hiddenCols[next]) {
			defColVisibility[col_index] = 0;
			next++;
		} else {
			defColVisibility[col_index] = 1;
		}
	}
	if(col_no==-1){
		for(var col_index=1; col_index < checkboxLen; col_index++){
			if (defColVisibility[col_index-1]) {
				c[col_index].checked = true;
			} else {
				c[col_index].checked=check;
			}
		}
	}
	for (var row_index = 0; row_index<rowsLen; row_index++) {
		var cels = rows[row_index].cells;
		if(col_no==-1){
			for(var col_index=0; col_index<colLen; col_index++){
				if(typeof cl[col_index+1]!="undefined" && cl[col_index+1].style.display!="none"){
					if(defColVisibility[col_index]){
						cels[col_index].style.display='table-cell';
					}
					else{
						cels[col_index].style.display=stl;
					}
				}
			}
		}
		else{
			cels[col_no].style.display=stl;
		}
	}
	// Unselect 'All' if any column is unselected //
	var allChecked = true;
	for(var col_index=1; col_index < c.length; col_index++){
		if (!c[col_index].checked) {
			allChecked = false;
			break;
		}
	}
	c[0].checked = allChecked;
	if(col_no==-1) c[0].checked = check;
}
function saveDefaultHiddenCols(tableId) {
    checkboxDiv = document.getElementById('checkboxes_'+tableId);
    checkboxLabels = checkboxDiv.getElementsByTagName('label');
    hiddenColsList = [];
    for(var i = 0; i<checkboxLabels.length; i++) {
        var checkbox = checkboxLabels[i].getElementsByTagName('input')[0];
        if (checkbox.type === 'checkbox' && checkbox.checked === false) {
            var labelName = checkboxLabels[i].textContent.trim();
            if (labelName !== 'All') {
                hiddenColsList.push(labelName);
            }
        }
    }
    defHiddenCols[tableId] = hiddenColsList;
}
function getParameterByName(name,url) {
	if (!url) url = window.location.href;
	name = name.replace(/[\[\]]/g, "\\$&");
	var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),results = regex.exec(url);
	if (!results) return null;
	if (!results[2]) return '';
	var arg_val=decodeURIComponent(results[2].replace(/\+/g, " "));
	return arg_val;
}
function scrollToInterfacePortGroup(){
    getDefaultFilterValues();
    if(defaultValues['intf_name'] && defaultValues['port_groupName']){
            var grp_header_id="toggle_"+defaultValues['intf_name']+"_portgrp_"+defaultValues['port_groupName'];
            var grp_body_id="hdiv_"+defaultValues['intf_name']+"_portgrp_"+defaultValues['port_groupName'];
            var grp_header_element=document.getElementById(grp_header_id);
            if(grp_header_element){
                    showModule("intf","divid_"+defaultValues['intf_name']);
                    grp_header_element.scrollIntoView();
                    toggleDiv(grp_body_id,grp_header_id);
            }
    }
}

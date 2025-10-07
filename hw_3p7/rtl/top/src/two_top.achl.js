//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';

module.exports = function top() {

    this.defineName('two_top');

    var u = require("../../lib/src/utils.js").init(this);

    // Instantiate FlexNoC
    this.instance({ name: 'fn', moduleName: 'Structurename' });

    // Instantiate AIU0
    this.instance({ name: 'aiu0', moduleName: 'top__aiu0' });


    // Make connections betwen AIU0 & FlexNoC
    this.always(function(){
       /*! for (var fnname in this.param.result.fn.Structure) {     */
       /*!    var w = this.param.result.fn.Structure[fnname] - 1;   */
       /*!    var m = fnname.match(/CTI_SFI_INIT_AceAIU1_(.*)$/);   */
       /*!    if ( m != null ) {                                    */
        /*! console.log(this.blah); */
       /*!       var concerto_name = "sfi_mst_"+m[1].toLowerCase(); */
       /*!       if (w > 0) {                                       */
                   fn.$fnname$ = aiu0.$concerto_name$[$w$, 0];
       /*!       } else {                                           */
       /*!          var mw = 0-w;                                   */
                   aiu0.$concerto_name$ = fn.$fnname$[$mw$, 0];
       /*!       }                                                  */     
       /*!    }                                                     */
       /*! }                                                        */
    });
    
};
//* eslint no-undef:0 *   /

//----------------------------------------------------------------------
// Copyright(C) 2014,2015 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

/********************************************************************************
 
Component Instantiation Utilities Library:  Shortcut functions for instantiating the GNC modules.
 
How to use it:

// 1. Require the library.  Please use the local variable "comp", so that
//    we can do search and replace in the future.

var comp = require("../../lib/src/libinst.js");

// 2. Initalize it by passing an reference to the current module.

comp.init(this);

// 3. Use it!

// Instantiate and connect up a free list manager.
//
comp.flm = function(FLM, 'myname', size,
                    'alloc_encoded',   'alloc_onehot', 'alloc_vld', 'alloc_ack',
                    'dealloc_encoded', 'dealloc_vld');

// Onehot Demux
// Muxes the one-bit 'gatesig' onto the 'outvec' at position 'offset'.
//
comp.onehot_demux('gatesig', 'offset_sample', 'sample_onehot', p.width_of_sample);
comp.onehot_demux(gatesig, offset, outvec, width);

// Onehot Decoder
// Include the width of the outdecode (onehot) vector.
//
comp.onehot_decode('invector', 'outdecode', width);

// Instantiate and connect up a FIFO
//
comp.fifo ( {
              moduleName: FIFO,
              name:       'rackFifo',
              width:      log_nOttCtrlEntries,
              depth:      rack_fifo_depth,

              push_data:  'rack_id_in',             pop_data:  'rack_id_out',
              push_valid: 'rresp_last_beat',        pop_valid: 'rack_id_vld',
              push_ready: 'accept_rresp_last_beat', pop_ready: 'ott_accept_rack_id'
             });

// Instantiate and connect up a MuxArb
// the "last" signal is optional (if omitted it's tied to '1'.b(1) )
// You don't need to specify the number of inputs, the function will figure it out.
//
comp.muxarb({ name: 'testMux', moduleName: MUXARB,
              outputs: ['out_data', 'out_vld', 'out_rdy', 'out_last'],
              inputs: [['in0_data', 'in0_vld', 'in0_rdy'],
                       ['in1_data', 'in1_vld', 'in1_rdy'],
                       ['in2_data', 'in2_vld', 'in2_rdy', 'in2_last'],
                       ['in3_data', 'in3_vld', 'in3_rdy'],
                       ['in4_data', 'in4_vld', 'in4_rdy'],
                       ['in5_data', 'in5_vld', 'in5_rdy']],
              width: 32});

// Old muxarb syntaxes for reference.  Not considered useful.
comp.muxarb2 ( [[in0_data, in0_vld, in0_ack],
                [in1_data, in1_vld, in1_ack],
                [out_data, out_vld, out_ack]],
               name, moduleName,
               width)
comp.muxarb5 ( in0_data, in0_vld, in0_ack,
               in1_data, in1_vld, in1_ack,
               in2_data, in2_vld, in2_ack,
               in3_data, in3_vld, in3_ack,
               in4_data, in4_vld, in4_ack,
               in5_data, in5_vld, in5_ack,
               out_data, out_vld, out_ack,
               name, moduleName,
               width)

********************************************************************************/

'use strict';

module.exports.init = function (mm){

    function o() {
    };

    // var comp = {};
    var comp = Object.create(o);
    comp.m = mm;

    /**
     * Create a mux as a case statement. (Onehot version -- not recommended)
     */
    comp.muxcase_onehot = function(outsig, in_prefix, sigwidth, sel, num_inputs) {
        this.m.outsig     = outsig;
        this.m.in_prefix  = in_prefix;
        this.m.sigwidth   = sigwidth;
        this.m.sel        = sel;
        this.m.num_inputs = num_inputs;

        this.m.always(function() {
            switch ($this.sel$) {
                /*! var arbitrary_limit = 16;                   */
                /*! for (var i = 0; i < this.num_inputs; i++) { */
                /*!     if (i > arbitrary_limit) {              */
                /*!         var prefix     = i % 4;             */
                /*!         var remainder  = i - prefix;        */
                /*!         var bitstring  = ['1', '2', '4', '8'][prefix]; */
                /*!         for (var j = 0; j < remainder; j+=4) {  */
                /*!            bitstring = bitstring + '0';     */
                /*!         }                                   */
                case '"bitstring"'.h($this.num_inputs$):     $this.outsig$ = $this.in_prefix$_$i$; break;
                /*!     } else { */
                case '"Math.pow(2,i)"'.d($this.num_inputs$): $this.outsig$ = $this.in_prefix$_$i$; break;
                /*!     }        */
                /*! } */
                default: $this.outsig$ = '0'.d($this.sigwidth$);
            }
        });
    }

    /**
     * Create a mux as an AND/OR tree. (Onehot version -- recommended for timing, although coverage tools don't like it much)
     */
    comp.muxcase_andor = function(outsig, in_prefix, sigwidth, sel, num_inputs) {
        this.m.outsig     = outsig;
        this.m.in_prefix  = in_prefix;
        this.m.sigwidth   = sigwidth;
        this.m.sel        = sel;
        this.m.num_inputs = num_inputs;

// This one doesn't seem to work on Mentor
//             this.m.comment(`
// #pragma cover_off`);

// This seems to be an older obsolete way of doing it.
//          this.m.comment(`VCS coverage off`);

// This way was recommended on some Cadence webpage by one of their Application Engineers:
//          this.m.comment(` pragma coverage off`);

// This way was recommended in an email from Mentor:
            this.m.comment(` coverage off`);

        this.m.always(function() {
            $this.outsig$ = 
                [$sel$[0]].repeat($this.sigwidth$) & $this.in_prefix$_0
            //!! for (var i = 1; i < this.num_inputs; i++) {
                | [$sel$["i"]].repeat($this.sigwidth$) & $this.in_prefix$_$i$
            //!! }
            ;
        });

//             this.m.comment(`
// #pragma cover_on`);
//          this.m.comment(`VCS coverage on`);
//          this.m.comment(` pragma coverage on`);
            this.m.comment(` coverage on`);

    }

    /**
     * Create a mux as a case statement.
     */
    comp.muxcase = function(outsig, in_prefix, sigwidth, sel, num_inputs) {
        this.m.outsig     = outsig;
        this.m.in_prefix  = in_prefix;
        this.m.sigwidth   = sigwidth;
        this.m.sel        = sel;
        this.m.num_inputs = num_inputs;

        this.m.always(function() {
            switch ($this.sel$) {
                /*! var sel_width  = this.log2ceil(this.num_inputs); */
                /*! for (var i = 0; i < this.num_inputs; i++) {      */
                case '"i"'.d($sel_width$): $this.outsig$ = $this.in_prefix$_$i$; break;
                /*! } */
                default: $this.outsig$ = '0'.d($this.sigwidth$);
            }
        });
    }

    /**
     * Instantiate and wire up a Free List Manager.
     */
    comp.flm = function(FLM, myname, size, alloc_encoded, alloc_onehot, alloc_vld, alloc_ack,
                        dealloc_onehot, dealloc_vld) {
        this.m.myname          = myname;
        this.m.alloc_encoded   = alloc_encoded;
        this.m.alloc_onehot    = alloc_onehot;
        this.m.alloc_vld       = alloc_vld;
        this.m.alloc_ack       = alloc_ack;
        this.m.dealloc_onehot  = dealloc_onehot;
        this.m.dealloc_vld     = dealloc_vld;

        this.m.p_flm = {
            num_entries:                size,
            num_reserved_entries:       2,
            num_deallocate_interfaces:  1,
            deallocate_encode:          this.m.false,
            num_allocate_interfaces:    1,
            allocate_encode:            this.m.false, // One-hot allocate output
        };
        this.m.instance({
            name:                        myname,
            moduleName:                  FLM,
            params:                      this.m.p_flm
        });
        this.m.always(function() {
            // Local Constants --------------------
            /*! var log_num_entries_m1 = Math.max(1, this.log2ceil(this.p_flm.num_entries)) - 1;      */
            /*! var dealloc_range;                                                                    */
            /*! var alloc_range;                                                                      */
            /*! if (this.p_flm.deallocate_encode) { dealloc_range = log_num_entries_m1; } else { dealloc_range = this.p_flm.num_entries - 1;} */
            /*! if (this.p_flm.allocate_encode)   { alloc_range   = log_num_entries_m1; } else { alloc_range   = this.p_flm.num_entries - 1;} */

            // Inputs
            $this.myname$.deallocate0           = $this.dealloc_onehot$[$dealloc_range$,0];
            $this.myname$.deallocate0_vld       = $this.dealloc_vld$;
            $this.myname$.allocate0_ack         = $this.alloc_ack$;

            // Outputs
            $this.alloc_onehot$[$alloc_range$,0]  = $this.myname$.allocate0;
            $this.alloc_vld$                      = $this.myname$.allocate0_vld;
        });

        // Also create decoded version from one-hot version
        comp.onehot_decode(this.m.alloc_onehot, this.m.alloc_encoded, this.m.p_flm.num_entries);
    }


    /**
     * Onehot Demux
     * 
     * Muxes the one-bit 'gatesig' onto the 'outvec' at position 'offset'.
     */
    // Usage: comp.onehot_demux('gatesig', 'offset_sample', 'sample_onehot', p.width_of_sample);
    comp.onehot_demux = function(gatesig, offset, outvec, width) {
        this.m.gatesig = gatesig;
        this.m.offset  = offset;
        this.m.outvec  = outvec;
        this.m.width   = width;

        // This is so simple that it hardly seems like a utility function is needed.  But just in case....
        this.m.always (function () {
            $this.outvec$   = [$this.gatesig$].repeat("this.width") & ('1'.b("this.width") << $this.offset$);
        });
    }


// This one was terrible.
// Leaving as a warning. (and as an example of a generated switch statement)
//
//      /**
//       * Onehot Decoder
//       */
//      comp.onehot_decode = function(invector, outdecode, width) {
//          this.m.invector  = invector;
//          this.m.outdecode = outdecode;
//          this.m.width     = width;
//          this.m.always(function() {
//              switch($this.invector$) {
//                  /*! for (var j=0; j < this.width; j++) {                  */
//              case '1'.b("this.width") << $j$: $this.outdecode$ = '"j"'.d("Math.max(1,this.log2ceil(this.width))"); break;
//                  /*! }                                                            */
//              default:  $this.outdecode$ = '0'.b("Math.max(1,this.log2ceil(this.width))");
//              }
//          });
//  // TODO Add SVA assert: $onehot(this.invector$)
//  //      u.assert2(acd, 'assert_onehot_' + outdecode + invector,
//  //                '@(posedge clk) disable iff (~reset_n) ( $onehot(' + invector + ') )',
//  //                'Onehot violation: ' + invector);
//      }


    /**
     * Onehot Decoder Supreme
     */
    comp.onehot_decode = function(invector, outdecode, width) {
        this.m.invector  = invector;
        this.m.outdecode = outdecode;
        this.m.width     = width;
        this.m.always(function() {
            //!! if (this.width == 1) {
            $this.outdecode$ = '0'.b(1);
            //!! }
            //!! var outpos_max = this.log2ceil( this.width );
            //!! for (var outpos=0; outpos < outpos_max; outpos++) {
            $this.outdecode$[ "outpos" ] = '0'.b(1)
            //!!     for ( var vecpos = 0; vecpos < this.width; vecpos++) {
            //!!         if ( (vecpos & ( 1 << outpos)) != 0) {
                | $this.invector$[ "vecpos" ]
            //!!         }
            //!!     }
            ;
            //!! }
        });
// TODO Add SVA assert: $onehot(this.invector$)
//      u.assert2(acd, 'assert_onehot_' + outdecode + invector,
//                '@(posedge clk) disable iff (~reset_n) ( $onehot(' + invector + ') )',
//                'Onehot violation: ' + invector);
    }


    /**
     * Instantiate and wire up a FIFO.
     */
    comp.fifo = function(config) {
        this.m.config = config;
        this.m.p_fifo = {
            depth:         this.m.config.depth,
            width:         this.m.config.width,
            push_type:     'RdyVld',
            pop_type:      'RdyVld',
            bypass_mode:   this.m.true,
            async:         this.m.false
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_fifo
        });
        this.m.always(function() {
            // Inputs
            /*! var width_m1 = this.config.width-1; */
            $this.config.name$.push_data["width_m1",0] = $this.config.push_data$["width_m1",0];
            $this.config.name$.push_valid              = $this.config.push_valid$;
            $this.config.name$.pop_ready               = $this.config.pop_ready$;

            // Outputs
            $this.config.pop_data$["width_m1",0]       = $this.config.name$.pop_data["width_m1",0];
            $this.config.pop_valid$                    = $this.config.name$.pop_valid;
            $this.config.push_ready$                   = $this.config.name$.push_ready;
        });
    }

    comp.fifo_slow = function(config) {
        this.m.config = config;
        this.m.p_fifo = {
            depth:         this.m.config.depth,
            width:         this.m.config.width,
            push_type:     'RdyVld',
            pop_type:      'RdyVld',
            bypass_mode:   this.m.false,
            async:         this.m.false
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_fifo
        });
        this.m.always(function() {
            // Inputs
            /*! var width_m1 = this.config.width-1; */
            $this.config.name$.push_data["width_m1",0] = $this.config.push_data$["width_m1",0];
            $this.config.name$.push_valid              = $this.config.push_valid$;
            $this.config.name$.pop_ready               = $this.config.pop_ready$;

            // Outputs
            $this.config.pop_data$["width_m1",0]       = $this.config.name$.pop_data["width_m1",0];
            $this.config.pop_valid$                    = $this.config.name$.pop_valid;
            $this.config.push_ready$                   = $this.config.name$.push_ready;
        });
    }

    comp.fifo2 = function(config) {
        this.m.config = config;
        this.m.p_fifo = {
            depth:         this.m.config.depth,
            width:         this.m.config.width,
            push_type:     'RdyVld',
            pop_type:      'RdyVld',
            bypass_mode:   this.m.true,
            async:         this.m.false,
            output_empty:  this.m.true
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_fifo
        });
        this.m.always(function() {
            // Inputs
            /*! var width_m1 = this.config.width-1; */
            $this.config.name$.push_data["width_m1",0] = $this.config.push_data$["width_m1",0];
            $this.config.name$.push_valid              = $this.config.push_valid$;
            $this.config.name$.pop_ready               = $this.config.pop_ready$;

            // Outputs
            $this.config.pop_data$["width_m1",0]       = $this.config.name$.pop_data["width_m1",0];
            $this.config.pop_valid$                    = $this.config.name$.pop_valid;
            $this.config.push_ready$                   = $this.config.name$.push_ready;
            $this.config.empty$                        = $this.config.name$.empty;
        });
    }

    comp.fifo2_slow = function(config) {
        this.m.config = config;
        this.m.p_fifo = {
            depth:         this.m.config.depth,
            width:         this.m.config.width,
            push_type:     'RdyVld',
            pop_type:      'RdyVld',
            bypass_mode:   this.m.false,
            async:         this.m.false,
            output_empty:  this.m.true
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_fifo
        });
        this.m.always(function() {
            // Inputs
            /*! var width_m1 = this.config.width-1; */
            $this.config.name$.push_data["width_m1",0] = $this.config.push_data$["width_m1",0];
            $this.config.name$.push_valid              = $this.config.push_valid$;
            $this.config.name$.pop_ready               = $this.config.pop_ready$;

            // Outputs
            $this.config.pop_data$["width_m1",0]       = $this.config.name$.pop_data["width_m1",0];
            $this.config.pop_valid$                    = $this.config.name$.pop_valid;
            $this.config.push_ready$                   = $this.config.name$.push_ready;
            $this.config.empty$                        = $this.config.name$.empty;
        });
    }


    /**
     * Instantiate and wire up a MUXARB.
     *
     * The signame_last field of each input is optional and defaults to asserted.
     */
    comp.muxarb = function(config) {
        this.m.config = config;
        this.m.number_of_mux_inputs = this.m.config.inputs.length;
        this.m.width                = this.m.config.width;
        this.m.p_muxarb = {
            number_of_inputs:        this.m.number_of_mux_inputs,
            width:                   this.m.width,
            sink_type:               'RdyVld',
            pipeline:                this.m.false,
            sfi_compliant:           this.m.false,
            arb_priority:            'RoundRobin'
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_muxarb
        });
        this.m.always(function() {
            /*! var width_m1 = this.width - 1;                                                        */
            /*! var input_i;                                                                          */
            /*! var lastsig = '';                                                                     */

            // Inputs
            /*! for (var i=0; i<this.number_of_mux_inputs; i++) {                                     */
            /*!     input_i = this.config.inputs[i];*/
                    $this.config.name$.sink$i$_data["width_m1",0] = "input_i[0]"["width_m1",0];
                    $this.config.name$.sink$i$_valid              = "input_i[1]";
                    // tied to 1'b1 when last-beat signalling is not used.
                    /*! if (input_i.length < 4) { */
                            $this.config.name$.sink$i$_last = '1'.b(1);
                    /*! } else { */
                            $this.config.name$.sink$i$_last = "input_i[3]";
                    /*! } */
            /*! }                                                                                     */
            // Note: source type == sink_type
            $this.config.name$.source_ready         = "this.config.outputs[2]";

            // Outputs
//          "this.config.outputs[0]"["width_m1",0]  = $this.config.name$.source_data["width_m1",0];
//          "this.config.outputs[1]"                = $this.config.name$.source_valid;
//          "this.config.outputs[3]"                = $this.config.name$.source_last;
            /*! var iojs_workaround = this.config.outputs[0];*/
            $iojs_workaround$["width_m1",0]  = $this.config.name$.source_data["width_m1",0];
            /*! iojs_workaround = this.config.outputs[1];*/
            $iojs_workaround$                = $this.config.name$.source_valid;
            /*! iojs_workaround = this.config.outputs[3];*/
            $iojs_workaround$                = $this.config.name$.source_last;
            /*! for (var i=0; i<this.number_of_mux_inputs; i++) {                                     */
            /*!     input_i = this.config.inputs[i];*/
//                  "input_i[2]"      = $this.config.name$.sink$i$_ready;
                    /*! var iojs_workaround = input_i[2];*/
                    $iojs_workaround$      = $this.config.name$.sink$i$_ready;
            /*! }                                                                                     */
        });
    }

    comp.muxarb_sfi = function(config) {
        this.m.config = config;
        this.m.number_of_mux_inputs = this.m.config.inputs.length;
        this.m.width                = this.m.config.width;
        this.m.p_muxarb = {
            number_of_inputs:        this.m.number_of_mux_inputs,
            width:                   this.m.width,
            sink_type:               'RdyVld',
            pipeline:                this.m.false,
            sfi_compliant:           this.m.true,
            arb_priority:            'RoundRobin'
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_muxarb
        });
        this.m.always(function() {
            /*! var width_m1 = this.width - 1;                                                        */
            /*! var input_i;                                                                          */
            /*! var lastsig = '';                                                                     */

            // Inputs
            /*! for (var i=0; i<this.number_of_mux_inputs; i++) {                                     */
            /*!     input_i = this.config.inputs[i];*/
                    $this.config.name$.sink$i$_data["width_m1",0] = "input_i[0]"["width_m1",0];
                    $this.config.name$.sink$i$_valid              = "input_i[1]";
                    // tied to 1'b1 when last-beat signalling is not used.
                    /*! if (input_i.length < 4) { */
                            $this.config.name$.sink$i$_last = '1'.b(1);
                    /*! } else { */
                            $this.config.name$.sink$i$_last = "input_i[3]";
                    /*! } */
            /*! }                                                                                     */
            // Note: source type == sink_type
            $this.config.name$.source_ready         = "this.config.outputs[2]";

            // Outputs
//          "this.config.outputs[0]"["width_m1",0]  = $this.config.name$.source_data["width_m1",0];
//          "this.config.outputs[1]"                = $this.config.name$.source_valid;
//          "this.config.outputs[3]"                = $this.config.name$.source_last;
            /*! var iojs_workaround = this.config.outputs[0];*/
            $iojs_workaround$["width_m1",0]  = $this.config.name$.source_data["width_m1",0];
            /*! iojs_workaround = this.config.outputs[1];*/
            $iojs_workaround$                = $this.config.name$.source_valid;
            /*! iojs_workaround = this.config.outputs[3];*/
            $iojs_workaround$                = $this.config.name$.source_last;
            /*! for (var i=0; i<this.number_of_mux_inputs; i++) {                                     */
            /*!     input_i = this.config.inputs[i];*/
//                  "input_i[2]"      = $this.config.name$.sink$i$_ready;
                    /*! var iojs_workaround = input_i[2];*/
                    $iojs_workaround$      = $this.config.name$.sink$i$_ready;
            /*! }                                                                                     */
        });
    }


    /**
     * Instantiate and wire up a MULTIFIFO
     *
     * The signame_last field of each input is optional and defaults to asserted.
     */
    comp.multi_fifo = function(config) {
        this.m.config = config;
        this.m.number_of_mux_inputs = this.m.config.inputs.length;
        this.m.width                = this.m.config.width;
        this.m.pop_type             = 'RdyVld';
        this.m.push_type            = 'RdyVld';
        this.m.p_multififo = {
            number_of_inputs:        this.m.number_of_mux_inputs,
            width:                   this.m.width,
            depth:                   this.m.config.depth,
            push_type:               this.m.push_type,
            pop_type:                this.m.pop_type,
            async:                   this.m.false
        };
        this.m.instance({
            name:                        this.m.config.name,
            moduleName:                  this.m.config.moduleName,
            params:                      this.m.p_multififo
        });
        this.m.always(function() {
            /*! var width_m1 = this.width - 1;                                                        */
            /*! var input_i;                                                                          */
            /*! var lastsig = '';                                                                     */

            // Inputs
            /*! for (var i=0; i<this.number_of_mux_inputs; i++) {                                     */
            /*!     input_i = this.config.inputs[i];*/
                    $this.config.name$.push$i$_data["width_m1",0] = "input_i[0]"["width_m1",0];
                    $this.config.name$.push$i$_valid              = "input_i[1]";
                    // TODO Allow "last" signaling
                 // // tied to 1'b1 when last-beat signalling is not used.
                 // /*! if (input_i.length < 4) { */
                 //         $this.config.name$.push$i$_last = '1'.b(1);
                 // /*! } else { */
                 //         $this.config.name$.push$i$_last = "input_i[3]";
                 // /*! } */
            /*! }                                                                                     */

            /*! if (this.pop_type         == 'RdyVld' ) { */
                    $this.config.name$.pop_ready         = "this.config.outputs[2]";
            /*! } else { */
                    $this.config.name$.pop_ack           = "this.config.outputs[2]";
            /*! }  */

            // Outputs
//          "this.config.outputs[0]"["width_m1",0]  = $this.config.name$.pop_data["width_m1",0];
//          "this.config.outputs[1]"                = $this.config.name$.pop_valid;
            /*! var iojs_workaround = this.config.outputs[0];*/
            $iojs_workaround$["width_m1",0]  = $this.config.name$.pop_data["width_m1",0];
            /*! iojs_workaround = this.config.outputs[1];*/
            $iojs_workaround$                = $this.config.name$.pop_valid;

          //"this.config.outputs[3]"                = $this.config.name$.pop_last; // TODO Allow "last" signaling
            /*! for (var i=0; i<this.number_of_mux_inputs; i++) {                                     */
            /*!     input_i = this.config.inputs[i];*/
            /*!     if (this.push_type         == 'RdyVld' ) { */
//                      "input_i[2]"      = $this.config.name$.push$i$_ready;
                        /*! var iojs_workaround = input_i[2];*/
                        $iojs_workaround$      = $this.config.name$.push$i$_ready;
            /*!     } else { */
//                      "input_i[2]"      = $this.config.name$.push$i$_ack;
                        /*! var iojs_workaround = input_i[2];*/
                        $iojs_workaround$      = $this.config.name$.push$i$_ack;
            /*!     } */
            /*! }                                                                                     */
        });
    }



    return comp;
}

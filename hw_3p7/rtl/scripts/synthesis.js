'use strict';

var exec = require('child_process').exec,
    expect = require('chai').expect;

//describe('Synthesis Compile Report', function () {
    
    //it('AIU - compile check', function (done) {

       //exec('grep -RI "Error:" rtl/aiu/synthesis/syn.aiu_*/dc_shell.log | wc -l', function (e, sto1, ste1) {
            //expect(sto1).to.equal('0\n');
            //done();
        //});

    //});

    //it('DCE - compile check', function (done) {

       //exec('grep -RI "Error:" rtl/dce/synthesis/syn.dce_*/dc_shell.log | wc -l', function (e, sto1, ste1) {
            //expect(sto1).to.equal('0\n');
            //done();
        //});

    //});

    //it('DMI - compile check', function (done) {

       //exec('grep -RI "Error:" rtl/dmi/synthesis/syn.dmi_*/dc_shell.log | wc -l', function (e, sto1, ste1) {
            //expect(sto1).to.equal('0\n');
            //done();
        //});

    //});

//});

describe('Synthesis Timing Report', function () {

    it('AIU - max timing check', function (done) {

       exec('grep -RI "slack (VIOLATED" rtl/aiu/synthesis/syn.aiu_*/reports/timing_max.rpt | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });

    });

    it('DCE - max timing check', function (done) {

       exec('grep -RI "slack (VIOLATED" rtl/dce/synthesis/syn.dce_*/reports/timing_max.rpt | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });

    });

    it('DMI - max timing check', function (done) {

       exec('grep -RI "slack (VIOLATED" rtl/dmi/synthesis/syn.dmi_*/reports/timing_max.rpt | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });

    });

});

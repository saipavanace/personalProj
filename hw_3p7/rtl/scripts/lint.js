'use strict';

var exec = require('child_process').exec,
    expect = require('chai').expect;

describe('ESLint Report', function () {

    it('AIU', function (done) {

       exec('grep -RI "error " rtl/aiu/eslint/eslint.aiu/eslint.log | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });
    });

    it('DCE', function (done) {

       exec('grep -RI "error " rtl/dce/eslint/eslint.dce/eslint.log | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });
    });

    it('DMI', function (done) {

       exec('grep -RI "error " rtl/dmi/eslint/eslint.dmi/eslint.log | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });
    });

});

describe('Spyglass Report', function () {

    it('AIU', function (done) {

       exec('grep -RI "Warning \|Error " rtl/aiu/lint/lint.aiu/aiu/consolidated_reports/top__top__coh__aiu00_Design_Read/moresimple.rpt | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });
    });

    it('DCE', function (done) {

       exec('grep -RI "Warning \|Error " rtl/dce/lint/lint.dce/dce/consolidated_reports/top__top__coh__dce_Design_Read/moresimple.rpt | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });
    });

    it('DMI', function (done) {

       exec('grep -RI "Warning \|Error " rtl/dmi/lint/lint.dmi/dmi/consolidated_reports/top__top__coh__dmi_Design_Read/moresimple.rpt | wc -l', function (e, sto1, ste1) {
            expect(sto1).to.equal('0\n');
            done();
        });
    });

});

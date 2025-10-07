#include "Vdmi.h"
#include "verilated.h"
#include "verilated_vcd_sc.h"
#include <iostream>
#include <typeinfo>
#include <systemc.h>

vluint64_t main_time = 0;

double sc_time_stamp () {
    return main_time;
}

SC_MODULE (stim) {
    // I/O
    sc_in<bool> clk;
    sc_in<bool> reset_n;
    <% obj.portNameList.forEach(function (portObj) { %>
    <%    if ((portObj.name !== 'clk') && (portObj.name !== 'reset_n')) { %>
    sc_<%=(portObj.direction === 'input') ? 'out' : 'in'%><<%=(portObj.size === 1) ? 'bool' : (portObj.size <= 32) ? 'uint' : 'sc_bv<256> '%>><%=portObj.name%>;
    <%    } %>
    <% }); %>

    bool sending_data;
    int r_count;
    int data_count;
    bool mrd_out;
    int mrd_out_count;
    int data_left;

    void drive_dmi_nd_rx() {
        if (mrd_out) {
            smi_nd_msg1_rx_ndp_valid.write(1);
            smi_nd_msg1_rx_ndp_body.write((1 << 20) | VL_RANDOM_Q(20));
            smi_nd_msg1_rx_ndp_transaction_id.write(mrd_out_count);
        } else {
            smi_nd_msg1_rx_ndp_valid.write(0);
        }
    }

    void drive_dmi_d_tx() {
        smi_d_msg1_tx_ndp_ready.write(1);
    }

    void drive_ar() {
        if (sending_data) {
            axi_mst_arready.write(0);
        } else {
            axi_mst_arready.write(1);
        }
    }

    void mon_nd_rx() {
        if (smi_nd_msg1_rx_ndp_valid.read() & smi_nd_msg1_rx_ndp_ready.read()) {
            cout << sc_core::sc_time_stamp() << ": " << "nd_msg1_rx" << endl;
            mrd_out_count--;
        }
        mrd_out = mrd_out_count > 0;
    }

    void mon_d_tx() {
        if (smi_d_msg1_tx_ndp_valid.read() & smi_d_msg1_tx_ndp_ready.read()) {
            cout << sc_core::sc_time_stamp() << ": " << "d_msg1_tx: count: " << data_count << endl;
            data_count++;
            if (data_count > 3) {
                data_count = 0;
                data_left--;
                if (data_left == 0) {
                    sc_stop();
                }
            }
        }
    }

    void mon_ar() {
        if (axi_mst_arvalid.read() & axi_mst_arready.read()) {
            cout << sc_core::sc_time_stamp() << ": " << "axi ar trans: id: " << axi_mst_arid.read() << endl;
            sending_data = 1;
        }
    }

    void drive_r() {
        if (sending_data) {
            axi_mst_rvalid.write(1);
        } else {
            axi_mst_rvalid.write(0);
        }
        // cout << sc_core::sc_time_stamp() << ": sending_data: " << sending_data << endl;
    }

    void mon_r() {
        if (axi_mst_rvalid.read() & axi_mst_rready.read()) {
            cout << sc_core::sc_time_stamp() << ": axi r trans: count: " << r_count << endl;
            // cout << sc_core::sc_time_stamp() << ": " << r_count << endl;
            r_count++;
            if (r_count > 3) {
                r_count = 0;
                sending_data = 0;
            }
        }
    }

    SC_CTOR (stim) {
        // Drivers
        SC_METHOD(drive_dmi_nd_rx);
        sensitive << clk.pos();
        SC_METHOD(drive_dmi_d_tx);
        sensitive << clk.pos();
        SC_METHOD(drive_ar);
        sensitive << clk.pos();
        SC_METHOD(drive_r);
        sensitive << clk.pos();

        // Monitors
        SC_METHOD(mon_nd_rx);
        sensitive << clk.neg();
        SC_METHOD(mon_d_tx);
        sensitive << clk.neg();
        SC_METHOD(mon_ar);
        sensitive << clk.neg();
        SC_METHOD(mon_r);
        sensitive << clk.neg();

        sending_data = 0;
        r_count = 0;
        data_count = 0;
        mrd_out_count = 10;
        data_left = 10;
    }
};

int sc_main(int argc, char** argv) {
    // clk
    sc_clock clk ("clk");

    // Signals
    <% obj.portNameList.forEach(function (portObj) { %>
    <%    if (portObj.name !== 'clk') { %>
    sc_signal<<%=(portObj.size === 1) ? 'bool' : (portObj.size <= 32) ? 'uint' : 'sc_bv<256> '%>><%=portObj.name%>;
    <%    } %>
    <% }); %>

    Verilated::commandArgs(argc, argv);

    stim tb_inst("stim");
    Vdmi* top = new Vdmi("top");

    // If trace
    Verilated::traceEverOn(true);
    VerilatedVcdSc* tfp = new VerilatedVcdSc;
    top->trace(tfp, 99);
    tfp->open("sim.vcd");
    // end if trace

    // DUT Connections
    <% obj.portNameList.forEach(function (portObj) { %>
    top-><%=portObj.name%>(<%=portObj.name%>);
    <% }); %>

    // Stim Connections
    <% obj.portNameList.forEach(function (portObj) { %>
    tb_inst.<%=portObj.name%>(<%=portObj.name%>);
    <% }); %>

    reset_n.write(0);
    cout << sc_core::sc_time_stamp() << ": in reset" << endl;
    sc_start(10, SC_NS);
    reset_n.write(1);
    cout << sc_core::sc_time_stamp() << ": out of reset" << endl;
    sc_start();
    // If trace
    tfp->close();
    // end if trace
    exit(0);
}

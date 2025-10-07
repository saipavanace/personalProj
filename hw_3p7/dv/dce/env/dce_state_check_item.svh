class state_check_item;
	local bit m_expect;
	local bit m_valid;
	local bit m_complete;
	local int m_expect_count;
	local int m_valid_count;
	local string m_name;
	time m_time_seenq[$];

    extern function new (string name);
    extern function string get_name();
	extern function void set_expect();
	extern function void clear_expect();
	extern function void clear_one_expect();
	extern function void set_complete();
	extern function void set_valid(time time_seen);
	extern function bit is_expect();
	extern function bit is_valid();
	extern function bit is_complete();
	extern function int get_valid_count();
    extern function int get_expect_count();
	extern function string convert2string();

endclass: state_check_item

function state_check_item::new(string name);
    m_name         = name;
	m_expect       = 0;
	m_valid        = 0;
	m_expect_count = 0;
	m_valid_count  = 0;
	m_complete     = 0;
    m_time_seenq.delete();
endfunction: new

function string state_check_item::get_name();
	return m_name;
endfunction: get_name

function void state_check_item::set_complete();
	m_complete = 1;
endfunction:set_complete

function void state_check_item::set_expect();
	m_expect = 1;
	m_expect_count++;
	m_complete = 0;
endfunction:set_expect

function void state_check_item::clear_one_expect();
	if(m_expect_count > 0)
		m_expect_count--;
	if(m_expect_count == 0)
		m_expect = 0;
	
	m_complete = ((m_expect == m_valid) && (m_expect_count == m_valid_count)) ? 1 : 0;
endfunction:clear_one_expect

function void state_check_item::clear_expect();
	m_expect = 0;
	m_expect_count = 0;
	m_complete = 0;
endfunction:clear_expect

function void state_check_item::set_valid(time time_seen);
	m_valid = 1;
	m_time_seenq.push_back(time_seen);
	m_valid_count++;
	m_complete = ((m_expect == m_valid) && (m_expect_count == m_valid_count)) ? 1 : 0;
endfunction:set_valid

function bit state_check_item::is_expect();
	return m_expect;
endfunction:is_expect

function bit state_check_item::is_valid();
	return m_valid;
endfunction:is_valid

function int state_check_item::get_valid_count();
	return m_valid_count;
endfunction: get_valid_count

function int state_check_item::get_expect_count();
	return m_expect_count;
endfunction: get_expect_count

function bit state_check_item::is_complete();
	return ((m_expect == m_valid) && (m_expect_count == m_valid_count) && m_complete);
endfunction:is_complete

function string state_check_item::convert2string();
	string s;
	string vld_time_s;
     
    foreach (m_time_seenq[i]) begin
		$sformat(vld_time_s, "%s [%0d => %0t], ", vld_time_s, i, m_time_seenq[i]);
    end
	//$sformat(vld_time_s, "", );
	$sformat(s, " %0s %0s and %0s and SM is %0s", 
	s, 
	m_expect ? ($sformatf("expected %0s", (m_expect_count == 1) ? "once" : $sformatf("%0d times", m_expect_count))) : "not expected",
	m_valid ? $sformatf("valid at %0s",vld_time_s) : "not valid",
    is_complete() ? "complete" : "not complete"
    );
   
    return s;

endfunction:convert2string


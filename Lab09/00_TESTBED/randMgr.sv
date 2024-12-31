`ifndef RANDMGR
`define RANDMGR

`include "Usertype.sv"
`include "../00_TESTBED/utility.sv"
import usertype::*;

class randMgr;
    function new(int seed);
        this.srandom(seed);
        this._logger = new("randMgr");

        enumRandList();
    endfunction

    // this function utilizes "enum" in system verilog
    function void enumRandList();
        Action a;
        Formula_Type ft;
        Mode m;

        // the class is first initialized into the first element of ENUM
        a = a.first(); // a = 2'h0 (action)
        ft = ft.first(); // ft = 3'h0 (formula type)
        m = m.first(); // m = Insensitive (mode)

        // a.num() returns the total number of values in the Action enumeration
        for(int i=0 ; i<a.num() ; ++i)begin
            actions.push_back(a);
            a = a.next();
        end

        for(int i=0 ; i<ft.num() ; ++i)begin
            formulaTypes.push_back(ft);
            ft = ft.next();
        end

        for(int i=0 ; i<m.num() ; ++i)begin
            modes.push_back(m);
            m = m.next();
        end

        // this function will make three dynamic array actions, formulaTypes,
        // and modes be populated for all possible values defined in ENUM
    endfunction

    // Getter
    function reportTable getTable();
        reportTable dataTable;
        dataTable = new("Random Data");
        dataTable.defineCol("Data");
        dataTable.defineCol("Value");
        dataTable.newRow();
        dataTable.addCell("Action");
        dataTable.addCell($sformatf("%s", action.name()));
        dataTable.newRow();
        dataTable.addCell("Formula type");
        dataTable.addCell($sformatf("%s", formulaType.name()));
        dataTable.newRow();
        dataTable.addCell("Mode");
        dataTable.addCell($sformatf("%s", mode.name()));
        dataTable.newRow();
        dataTable.addCell("Index A");
        dataTable.addCell($sformatf("%4d / %5d / %3h", indexA, $signed(indexA), indexA));
        dataTable.newRow();
        dataTable.addCell("Index B");
        dataTable.addCell($sformatf("%4d / %5d / %3h", indexB, $signed(indexB), indexB));
        dataTable.newRow();
        dataTable.addCell("Index C");
        dataTable.addCell($sformatf("%4d / %5d / %3h", indexC, $signed(indexC), indexC));
        dataTable.newRow();
        dataTable.addCell("Index D");
        dataTable.addCell($sformatf("%4d / %5d / %3h", indexD, $signed(indexD), indexD));
        dataTable.newRow();
        dataTable.addCell("Date\(M/D\)");
        dataTable.addCell($sformatf("%2d / %2d", month, day));
        dataTable.newRow();
        dataTable.addCell("Data No.");
        dataTable.addCell($sformatf("%3d", dataNo));
        return dataTable;
    endfunction

    // Dumper
    function void display();
        reportTable dataTable = getTable();
        dataTable.show();
    endfunction

    // add a constraint class to constraint the random value generated
    // You can specify a lower and an upper limit as an alternative to the expression shown below using an inside operator.
    constraint range{
        this.action inside{actions};
        // {this.action == Check_Valid_Date};
        // {this.action == Index_Check};
        // {this.action == Update};
        // this.formulaType inside{formulaTypes};
        // {this.formulaType == Formula_H};
        this.mode inside{modes};
        this.indexA inside{[0:(2**$bits(Index)-1)]};
        this.indexB inside{[0:(2**$bits(Index)-1)]};
        this.indexC inside{[0:(2**$bits(Index)-1)]};
        this.indexD inside{[0:(2**$bits(Index)-1)]};
        this.month inside{[1:12]};
        // this.date.D inside{[1:paramMgr::getNbOfDays(this.date.M)]};
        1 <= this.day;
        this.day <= paramMgr::getNbOfDays(this.month); // get the days given month
        this.dataNo inside{[0:(2**$bits(Data_No)-1)]};
    }
    
    // rand: create random value of the class
    rand Action action; 
    rand Formula_Type formulaType;
    rand Mode mode;
    rand Index indexA; // index is logic [11:0]
    rand Index indexB;
    rand Index indexC;
    rand Index indexD;
    rand Month month;
    rand Day day;
    rand Data_No dataNo;

    local logger _logger;

    Action actions[$]; // dynamic number of actions
    Formula_Type formulaTypes[$]; // dynamic number of formulaTypes
    Mode modes[$]; // dynamic number of modes
endclass

`endif
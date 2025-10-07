import os, os.path

basepath = '.'

for fname in os.listdir(basepath):
    path = os.path.join(basepath, fname)
    if os.path.isdir(path):
        print('Found directory: %s' % path)
        os.chdir( path )
        os.system("cp $WORK_TOP/dv/common/checker/src/basepacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/CacheLineState.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/CacheModel.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/CbiPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/checker_report.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/CoherencyChecker.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/DceDirMgrPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/DceProbePacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/DpiCstructs.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/libInclude.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/MemoryModel.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/packetInclude.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/PacketProcessor.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/ReadAddrPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/ReadRespPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SFIReqPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SFIRespPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SFITransaction.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SnoopAddrPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SnoopDataPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SnoopRespPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/SnoopTracker.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/systemcacheclass.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/Transaction.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/AxiTransaction.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/DmiTransaction.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/DmiTop.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/CMC_Cache.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/WriteAddrPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/WriteDataPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/WriteRespPacket.h dv"); 
        os.system("cp $WORK_TOP/dv/common/checker/src/*.cpp dv");
        os.system("cp dv/Makefile.checker .");
        os.system("make -f Makefile.checker");
        path = os.path.join('','run')
        for fname1 in os.listdir(path):
            path1 = os.path.join(path, fname1)
            if os.path.isdir(path1):
                print('Found subdirectory: %s' % path1)
                os.chdir( path1 )
                os.system("qsub -V -e /dev/null -o /dev/null -cwd -b y \"../../lib64/checker -o \"");
                os.chdir("../..");
        os.chdir("..");

//`timescale 1 ps / 1 ps
// synopsys translate_on
`include "./delta_sigma.sv"

// 0         4   ChunkID          Contains the letters "RIFF" in ASCII form
//                                (0x52494646 big-endian form).
// 4         4   ChunkSize        36 + SubChunk2Size, or more precisely:
//                                4 + (8 + SubChunk1Size) + (8 + SubChunk2Size)
//                                This is the size of the rest of the chunk 
//                                following this number.  This is the size of the 
//                                entire file in bytes minus 8 bytes for the
//                                two fields not included in this count:
//                                ChunkID and ChunkSize.
// 8         4   Format           Contains the letters "WAVE"
//                                (0x57415645 big-endian form).

// The "WAVE" format consists of two subchunks: "fmt " and "data":
// The "fmt " subchunk describes the sound data's format:

// 12        4   Subchunk1ID      Contains the letters "fmt "
//                                (0x666d7420 big-endian form).
// 16        4   Subchunk1Size    16 for PCM.  This is the size of the
//                                rest of the Subchunk which follows this number.
// 20        2   AudioFormat      PCM = 1 (i.e. Linear quantization)
//                                Values other than 1 indicate some 
//                                form of compression.
// 22        2   NumChannels      Mono = 1, Stereo = 2, etc.
// 24        4   SampleRate       8000, 44100, etc.
// 28        4   ByteRate         == SampleRate * NumChannels * BitsPerSample/8
// 32        2   BlockAlign       == NumChannels * BitsPerSample/8
//                                The number of bytes for one sample including
//                                all channels. I wonder what happens when
//                                this number isn't an integer?
// 34        2   BitsPerSample    8 bits = 8, 16 bits = 16, etc.
//           2   ExtraParamSize   if PCM, then doesn't exist
//           X   ExtraParams      space for extra parameters

// The "data" subchunk contains the size of the data and the actual sound:

// 36        4   Subchunk2ID      Contains the letters "data"
//                                (0x64617461 big-endian form).
// 40        4   Subchunk2Size    == NumSamples * NumChannels * BitsPerSample/8
//                                This is the number of bytes in the data.
//                                You can also think of this as the size
//                                of the read of the subchunk following this 
//                                number.
// 44        *   Data             The actual sound data.
//`define DATA_SIZE 16

/// Gnerate a ltspice pwl file by reading the content of a wav file and feeding it to the 
/// delta sigma module. 

class WaveFileReader;
    integer file;
    int chunkSize;
    int format;
    shortint numberOfChannel;
    int sampleRate;
    shortint bitsPerSample;
    int dataSize;
    localparam SEEK_ORG = 0;
    localparam SEEK_CUR = 1;
    int dataOffset = 44;
    int interval;
    longint picoInSecond = 64'd1000000000000;

    function new(string fileName);
        file = $fopen(fileName, "rb");
        chunkSize = readInt(4);
        format = readInt(8);
        numberOfChannel = readShort(22);
        sampleRate = readInt(24);
        bitsPerSample = readShort(34);
        dataSize = readInt(40);
        interval = picoInSecond / sampleRate;
    endfunction

    byte bbyte [1]; 
    function byte readByte (int offset);
        $fseek(file, offset, SEEK_ORG);
        $fread(bbyte, file);
        readByte = bbyte[0];
    endfunction
    
    byte int16 [0:1]; 
    function shortint readShort (int offset);
        $fseek(file, offset, SEEK_ORG);
        $fread(int16, file);
        readShort = { << shortint {int16[1], int16[0]}};
    endfunction
    
    byte int32 [0:3]; 
    function int readInt(int offset);
        $fseek(file,offset,SEEK_ORG);
        $fread(int32, file);
        readInt = { << int {int32[3], int32[2], int32[1], int32[0]}};
    endfunction

    function byte readNextDataByte ();
        readNextDataByte = readByte(dataOffset++);
    endfunction 

    function int close();
        $fclose(file);
        close = 0;
    endfunction
endclass

class PwlFileWriter;
    string _fileName;
    integer file;
    int _interval;
    function new(string fileName, int interval);
        _interval = interval;
        _fileName = fileName;
        file = $fopen(_fileName, "w");
        $fclose(file);
    endfunction

    function int appendToFile(string line);
        file = $fopen(_fileName, "a");
        $fwrite(file, line);
        $fclose(file);
    endfunction

    function addLine(int voltage);
        appendToFile($sformatf("\n+%0Dp %d", _interval, voltage));
    endfunction

endclass

module generatePwlFile #( parameter DATA_SIZE = 16 ) ();
    integer sampleCount = 0;
    WaveFileReader waveFile;
    PwlFileWriter pmlWriters [];

    reg [DATA_SIZE - 1:0] channelData [2];
    wire channelOut [2];
    
    reg reset = 0;
    reg clk = 0;

    delta_sigma #(.DATA_SIZE(DATA_SIZE)) left  (
        .data(channelData[0]),
        .clk(clk),
        .reset(reset),
        .dataOut(channelOut[0])
    );

    delta_sigma #(.DATA_SIZE(DATA_SIZE)) right  (
        .data(channelData[1]),
        .clk(clk),
        .reset(reset),
        .dataOut(channelOut[1])
    );

    always @(posedge clk) begin
        for (int channelIndex = 0; channelIndex < waveFile.numberOfChannel; channelIndex++) begin
            pmlWriters[channelIndex].addLine(channelOut[channelIndex]);
        end
    end
    
    initial begin 

        waveFile        = new("testData\\440.wav");

        $display("file descriptor: %b", waveFile.file);
        $display("chunkSize: %d", waveFile.chunkSize);
        $display("numberOfChannel: %d",waveFile.numberOfChannel);
        $display("sampleRate: %d", waveFile.sampleRate);
        $display("bitsPerSample: %d", waveFile.bitsPerSample);
        $display("dataSize***: %d", waveFile.dataSize);

        assert (DATA_SIZE == waveFile.bitsPerSample );
        pmlWriters = new [waveFile.numberOfChannel];

        for (int channelIndex = 0; channelIndex < waveFile.numberOfChannel; channelIndex++) begin
            $display("crating file :%0d", channelIndex+1);
            pmlWriters[channelIndex] = new($sformatf("testData\\pwl%0d.txt", channelIndex+1), waveFile.interval);
        end
        
        for (int i = 0 ; i < waveFile.dataSize && sampleCount < 10; i = i+(waveFile.numberOfChannel*(waveFile.bitsPerSample/8)) ) begin

            for (int channelIndex = 0; channelIndex<waveFile.numberOfChannel; channelIndex++ ) begin
                for (int chanelByteCount = 0; chanelByteCount<(waveFile.bitsPerSample/8); chanelByteCount++) begin
                    channelData[channelIndex] = (channelData[channelIndex] << 8) | waveFile.readNextDataByte();
                end 
            end

            for (int k = 0; k < waveFile.bitsPerSample+2; k++) begin 
                // making sure enough time has passed so the simulator will detect the clock change -
                // this depends on the value of `timesacele at eh begining of the file
                #10 
                clk = ~clk;
            end
            sampleCount = sampleCount+1;
        end 
    end
endmodule
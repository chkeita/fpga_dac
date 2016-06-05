//`timescale 1 ps / 1 ps
// synopsys translate_on


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


module readFile ();
    
    integer file;
    integer i;
    int chunkSize;
    int format;
    shortint numberOfChannel;
    int sampleRate;
    shortint bitsPerSample;
    int dataSize;
    localparam SEEK_ORG = 0;
    localparam SEEK_CUR = 1;
    byte memory [] ;
    
    byte int16 [0:1]; 
    function shortint readShort (int offset, integer file);
        begin
            $fseek(file,offset,SEEK_ORG);
            $fread(int16, file);
            readShort = { << shortint {int16[1], int16[0]}};
        end
    endfunction
    
    byte int32 [0:3]; 
    function int readInt(int offset, integer file);
        begin
            $fseek(file,offset,SEEK_ORG);
            $fread(int32, file);
            readInt = { << int {int32[3], int32[2], int32[1], int32[0]}};
        end
    endfunction
    
    initial begin 
        file = $fopen("testData\\440.wav", "rb");
        chunkSize = readInt(4,file);
        format = readInt(8, file);
        numberOfChannel = readShort(22, file);
        sampleRate = readInt(24, file);
        bitsPerSample = readShort(34, file);
        dataSize = readInt(40, file);
        memory = new [dataSize];
        
        $fread(memory, file);
        $display("file descriptor: %b", file);
        $display("chunkSize: %d",chunkSize);
        $display("numberOfChannel: %d",numberOfChannel);
        $display("sampleRate: %d",sampleRate);
        $display("bitsPerSample: %d", bitsPerSample);
        $display("dataSize: %d",dataSize);
        
        
        for (i = 0; i < dataSize;i = i+(numberOfChannel*(bitsPerSample/8)) ) begin
            $display("memory %d : %h", i, memory[i]);
        end 
    end
endmodule
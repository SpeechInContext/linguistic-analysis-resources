% This is a script to batch morph a directory of preprocessed .mat files
% from STRAIGHT.
% In the input directory, there should be two .mat files, one as the "A"
% side of the continuum and one as the "B" side.
%
% For instance, morphing a "sin" token to a "shin" token, there would be
% sin_shinA.mat (100% sin) and a sin_shinB.mat (100% shin) in the directory
%
% The script will create directories in the output directory for each such
% pair of .mat files it finds. In this created directory, all of the
% continuum will be saved with the pattern of "stimulus001.wav"

path = '/path/to/saved/straight/mat/directory';

outpath = '/path/to/output/directory';

continua = dir(path);

expansionRate = 1;
nOfSteps = 11;


cpath = outpath;

for cIdx = 1:length(continua)
    name = continua(cIdx).name
    
    if strcmp(name,'.')
        continue
    end
    if strcmp(name,'..')
        continue
    end
    if strcmp(name(end-4:end) , 'A.mat')
        continue
    end
    if strcmp(name(end-4:end) , 'B.mat')
        continue
    end
    name = name(1:end-4);
    outFileRootName = name;
    
    aname = [name 'A.mat'];
    bname = [name 'B.mat'];
    
    
    load(fullfile(path,aname));
    if exist('revisedData') ~= 1
        disp(['The file ' file ' is not a morphing substrate']);
        return;
    else
        mSubstrateA = revisedData;
    end;
    
    morphingRecord.directoryForA = path;
    morphingRecord.fileNameForA = aname;
    
    load(fullfile(path,bname));
    if exist('revisedData') ~= 1
        disp(['The file ' file ' is not a morphing substrate']);
        return;
    else
        mSubstrateB = revisedData;
    end;
    clear('revisedData');
    
    morphingRecord.directoryForB = path;
    morphingRecord.fileNameForB = bname;
    
    outFileDirecotry = cpath;
    %outFileRootName = 'testMorph';
    if fopen(outFileDirecotry) < 0
        mkdir(outFileDirecotry);
    end;
    
    morphingRecord.outFileDirecotry = outFileDirecotry;
    morphingRecord.outFileRootName = outFileRootName;
    morphingRecord.dataOfCreation = datestr(now);
    morphingRecord.computer = computer;
    morphingRecord.version = version;
    
    fs = mSubstrateA.samplintFrequency;
    
    if ischar(nOfSteps)
        nOfSteps = eval(nOfSteps);
    end;
    if ischar(expansionRate)
        expansionRate = eval(expansionRate);
    end;
    
    %nOfSteps = 11;
    deltaLambda = 1/(nOfSteps-1);
    morphingRateList = cell(nOfSteps,1);
    mSubstrateSynthesis = mSubstrateA;
    for ii = 1:nOfSteps
        lambda = (ii-1)*deltaLambda;
        currentMorphingRate = interpolateMorphingRate(mSubstrateA,mSubstrateB,lambda,expansionRate);
        mSubstrateSynthesis.temporalMorphingRate = currentMorphingRate;
        morphedSignal = generateMorphedSpeechNewAP(mSubstrateSynthesis);
        tmpSound = morphedSignal.outputBuffer;
        outFileName = [outFileDirecotry '/' outFileRootName num2str(ii,'%03d') ...
            '.wav'];
        maxAmplitude = max(abs(morphedSignal.outputBuffer));
        wavwrite(morphedSignal.outputBuffer/maxAmplitude*0.9,fs,16,outFileName);
        morphingRateList{ii} = currentMorphingRate;
    end;
    
    morphingRecord.morphingRateList = morphingRateList;
    morphingRecord.knobYdataForEndA = mSubstrateA.knobYdata;
    morphingRecord.knobYdataForEndB = mSubstrateB.knobYdata;
    morphingRecord.temporaAnchorOfSpeakerA = mSubstrateA.temporaAnchorOfSpeakerA;
    morphingRecord.temporaAnchorOfSpeakerB = mSubstrateB.temporaAnchorOfSpeakerB;
    %recordFileName = ['recordOf' outFileRootName datestr(now,30)];
    %eval(['save ' outFileDirecotry '/' recordFileName ' morphingRecord;']);
    
end
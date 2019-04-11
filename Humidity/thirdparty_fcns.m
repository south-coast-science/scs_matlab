classdef thirdparty_fcns
    methods (Static)
        function [DtN,Spl,TkC] = datenum8601(Str,Tok)
            % Convert an ISO 8601 formatted Date String (timestamp) to a Serial Date Number.
            
            % (c) 2015 Stephen Cobeldick
            %
            % ### Function ###
            %
            % Syntax:
            %  DtN = datenum8601(Str)
            %  DtN = datenum8601(Str,Tok)
            %  [DtN,Spl,TkC] = datenum8601(...)
            %
            % By default the function automatically detects all ISO 8601 timestamp/s in
            % the string, or use a token to restrict detection to only one particular style.
            %
            % The ISO 8601 timestamp style options are:
            % - Date in calendar, ordinal or week-numbering notation.
            % - Basic or extended format.
            % - Choice of date-time separator character ( @T_).
            % - Full or lower precision (trailing units omitted)
            % - Decimal fraction of the trailing unit.
            % These style options are illustrated in the tables below.
            %
            % The function returns the Serial Date Numbers of the date and time given
            % by the ISO 8601 style timestamp/s, the input string parts that are split
            % by the detected timestamps (i.e. the substrings not part of  any ISO 8601
            % timestamp), and string token/s that define the detected timestamp style/s.
            %
            % Note 1: Calls undocumented MATLAB function "datenummx".
            % Note 2: Unspecified month/date/week/day timestamp values default to one (1).
            % Note 3: Unspecified hour/minute/second timestamp values default to zero (0).
            % Note 4: Auto-detection mode also parses mixed basic/extended timestamps.
            %
            % See also DATESTR8601 DATEROUND CLOCK NOW DATENUM DATEVEC DATESTR NATSORT NATSORTROWS NATSORTFILES
            %
            % ### Examples ###
            %
            % Examples use the date+time described by the vector [1999,1,3,15,6,48.0568].
            %
            % datenum8601('1999-01-03 15:06:48.0568')
            %  ans = 730123.62972287962
            %
            % datenum8601('1999003T150648.0568')
            %  ans = 730123.62972287962
            %
            % datenum8601('1998W537_150648.0568')
            %  ans = 730123.62972287962
            %
            % [DtN,Spl,TkC] = datenum8601('A19990103B1999-003C1998-W53-7D')
            %  DtN = [730123,730123,730123]
            %  Spl = {'A','B','C','D'}
            %  TkC = {'ymd','*yn','*YWD'}
            %
            % [DtN,Spl,TkC] = datenum8601('1999-003T15')
            %  DtN = 730123.6250
            %  Spl = {'',''}
            %  TkC = {'*ynTH'}
            %
            % [DtN,Spl,TkC] = datenum8601('1999-01-03T15','*ymd')
            %  DtN = 730123.0000
            %  Spl = {'','T15'}
            %  TkC = {'*ymd'}
            %
            % ### ISO 8601 Timestamps ###
            %
            % The token consists of one letter for each of the consecutive date/time
            % units in the timestamp, thus it defines the date notation (calendar,
            % ordinal or week-date) and selects either basic or extended format:
            %
            % Input    | Basic Format             | Extended Format (token prefix '*')
            % Date     | In/Out | Input Timestamp | In/Out  | Input Timestamp
            % Notation:| <Tok>: | <Str> Example:  | <Tok>:  | <Str> Example:
            % =========|========|=================|=========|===========================
            % Calendar |'ymdHMS'|'19990103T150648'|'*ymdHMS'|'1999-01-03T15:06:48'
            % ---------|--------|-----------------|---------|---------------------------
            % Ordinal  |'ynHMS' |'1999003T150648' |'*ynHMS' |'1999-003T15:06:48'
            % ---------|--------|-----------------|---------|---------------------------
            % Week     |'YWDHMS'|'1998W537T150648'|'*YWDHMS'|'1998-W53-7T15:06:48'
            % ---------|--------|-----------------|---------|---------------------------
            %
            % Options for reduced precision timestamps, non-standard date-time separator
            % character, and the addition of a decimal fraction of the trailing unit:
            %
            % Omit trailing units (reduced precision), eg:                    | Output->Vector:
            % =========|========|=================|=========|=================|=====================
            %          |'Y'     |'1999W'          |'*Y'     |'1999-W'         |[1999,1,4,0,0,0]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            %          |'ymdH'  |'19990103T15'    |'*ymdH'  |'1999-01-03T15'  |[1999,1,3,15,0,0]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            % Select the date-time separator character (one of ' ','@','T','_'), eg:
            % =========|========|=================|=========|=================|=====================
            %          |'yn_HM' |'1999003_1506'   |'*yn_HM' |'1999-003_15:06' |[1999,1,3,15,6,0]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            %          |'YWD@H' |'1998W537@15'    |'*YWD@H' |'1998-W53-7@15'  |[1999,1,3,15,0,0]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            % Decimal fraction of trailing date/time value, eg:
            % =========|========|=================|=========|=================|=====================
            %          |'ynH3'  |'1999003T15.113' |'*ynH3'  |'1999-003T15.113'|[1999,1,3,15,6,46.80]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            %          |'YWD4'  |'1998W537.6297'  |'*YWD4'  |'1998-W53-7.6297'|[1999,1,3,15,6,46.08]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            %          |'y10'   |'1999.0072047202'|'*y10'   |'1999.0072047202'|[1999,1,3,15,6,48.06]
            % ---------|--------|-----------------|---------|-----------------|---------------------
            %
            % Note 5: This function does not check for ISO 8601 compliance: user beware!
            % Note 6: Date-time separator character must be one of ' ','@','T','_'.
            % Note 7: Date notations cannot be combined: note upper/lower case characters.
            %
            % ### Input & Output Arguments ###
            %
            % Inputs (*default):
            %  Str = DateString, possibly containing one or more ISO 8601 dates/timestamps.
            %  Tok = String, token to select the required date notation and format (*[]=any).
            %
            % Outputs:
            %  DtN = NumericVector of Serial Date Numbers, one from each timestamp in input <Str>.
            %  Spl = CellOfStrings, the strings before, between and after the detected timestamps.
            %  TkC = CellOfStrings, tokens of each timestamp notation and format (see tables).
            %
            % [DtN,Spl,TkC] = datenum8601(Str,*Tok)
            % Define "regexp" match string:
            if nargin<2 || isempty(Tok)
                % Automagically detect timestamp style.
                MtE = [...
                    '(\d{4})',... % year
                    '((-(?=(\d{2,3}|W)))?)',... % -
                    '(W?)',...    % W
                    '(?(3)(\d{2})?|(\d{2}(?=($|\D|\d{2})))?)',... % week/month
                    '(?(4)(-(?=(?(3)\d|\d{2})))?)',...   % -
                    '(?(4)(?(3)\d|\d{2})?|(\d{3})?)',... % day of week/month/year
                    '(?(6)([ @T_](?=\d{2}))?)',... % date-time separator character
                    '(?(7)(\d{2})?)',...  % hour
                    '(?(8)(:(?=\d{2}))?)',...  % :
                    '(?(8)(\d{2})?)',...  % minute
                    '(?(10)(:(?=\d{2}))?)',... % :
                    '(?(10)(\d{2})?)',... % second
                    '((\.\d+)?)']; % trailing unit decimal fraction
                % (Note: allows a mix of basic/extended formats)
            else
                % User requests a specific timestamp style.
                assert(ischar(Tok)&&isrow(Tok),'Second input <Tok> must be a string.')
                TkU = regexp(Tok,'(^\*?)([ymdnYWD]*)([ @T_]?)([HMS]*)(\d*$)','tokens','once');
                assert(~isempty(TkU),'Second input <Tok> is not supported: ''%s''',Tok)
                MtE = [TkU{2},TkU{4}];
                TkL = numel(MtE);
                Ntn = find(strncmp(MtE,{'ymdHMS','ynHMS','YWDHMS'},TkL),1,'first');
                assert(~isempty(Ntn),'Second input <Tok> is not supported: ''%s''',Tok)
                MtE = thirdparty_fcns.dn8601Usr(TkU,TkL,Ntn);
            end
            %
            assert(ischar(Str)&&size(Str,1)<2,'First input <Str> must be a string.')
            %
            % Extract timestamp tokens, return split strings:
            [TkC,Spl] = regexp(Str,MtE,'tokens','split');
            %
            [DtN,TkC] = cellfun(@thirdparty_fcns.dn8601Main,TkC);
            %
        end
        %----------------------------------------------------------------------END:datenum8601
        
        function [DtN,Tok] = dn8601Main(TkC)
            % Convert detected substrings into serial date number, create string token.
            %
            % Lengths of matched tokens:
            TkL = cellfun('length',TkC);
            % Preallocate Date Vector:
            DtV = [1,1,1,0,0,0];
            %
            % Create token:
            Ext = '*';
            Sep = [TkC{7},'HMS'];
            TkX = {['ymd',Sep],['y*n',Sep],['YWD',Sep]};
            Ntn = 1+(TkL(6)==3)+2*TkL(3);
            Tok = [Ext(1:+any(TkL([2,5,9,11])==1)),TkX{Ntn}(0<TkL([1,4,6,7,8,10,12]))];
            %
            % Convert date and time values to numeric:
            Idx = [1,4,6,8,10,12];
            for m = find(TkL(Idx))
                DtV(m) = sscanf(TkC{Idx(m)},'%f');
            end
            % Add decimal fraction of trailing unit:
            if TkL(13)>1
                if Ntn==2&&m==2 % Month (special case not converted by "datenummx"):
                    DtV(3) = 1+sscanf(TkC{13},'%f')*(datenummx(DtV+[0,1,0,0,0,0])-datenummx(DtV));
                else % All other date or time values (are converted by "datenummx"):
                    DtV(m) = DtV(m)+sscanf(TkC{13},'%f');
                end
                Tok = {[Tok,sprintf('%.0f',TkL(13)-1)]};
            else
                Tok = {Tok};
            end
            %
            % Week-numbering vector to ordinal vector:
            if Ntn==3
                DtV(3) = DtV(3)+7*DtV(2)-4-mod(datenummx([DtV(1),1,1]),7);
                DtV(2) = 1;
            end
            % Convert out-of-range Date Vector to Serial Date Number:
            DtN = datenummx(DtV) - 31*(0==DtV(2));
            % (Month zero is a special case not converted by "datenummx")
            %
        end
        %----------------------------------------------------------------------END:dn8601Main
        
        function MtE = dn8601Usr(TkU,TkL,Ntn)
            % Create "regexp" <match> string from user input token.
            %
            % Decimal fraction:
            if isempty(TkU{5})
                MtE{13} = '()';
            else
                MtE{13} = ['(\.\d{',TkU{5},'})'];
            end
            % Date-time separator character:
            if isempty(TkU{3})
                MtE{7} = '(T)';
            else
                MtE{7} = ['(',TkU{3},')'];
            end
            % Year and time tokens (year, hour, minute, second):
            MtE([1,8,10,12]) = {'(\d{4})','(\d{2})','(\d{2})','(\d{2})'};
            % Format tokens:
            if isempty(TkU{1}) % Basic
                MtE([2,5,9,11]) = {'()','()','()','()'};
            else % Extended
                MtE([2,5,9,11]) = {'(-)','(-)','(:)','(:)'};
            end
            % Date tokens:
            switch Ntn
                case 1 % Calendar
                    Idx = [2,5,7,9,11,13];
                    MtE([3,4,6]) = {'()', '(\d{2})','(\d{2})'};
                case 2 % Ordinal
                    Idx = [2,7,9,11,13];
                    MtE([3,4,5,6]) = {'()','()','()','(\d{3})'};
                case 3 % Week
                    Idx = [2,5,7,9,11,13];
                    MtE([3,4,6]) = {'(W)','(\d{2})','(\d{1})'};
            end
            %
            % Concatenate tokens into "regexp" match token:
            MtE(Idx(TkL):12) = {'()'};
            MtE = [MtE{:}];
            %
        end
        %----------------------------------------------------------------------END:dn8601Usr
        
        function b = xlscol(a)
            %   XLSCOL Convert Excel column letters to numbers or vice versa.
            %   B = XLSCOL(A) takes input A, and converts to corresponding output B.
            %   The input may be a number, a string, an array or matrix, an Excel
            %   range, a cell, or a combination of each within a cell, including nested
            %   cells and arrays. The output maintains the shape of the input and
            %   attempts to "flatten" the cell to remove nesting.  Numbers and symbols
            %   within strings or Excel ranges are ignored.
            %
            %   Examples
            %   --------
            %       xlscol(256)   % returns 'IV'
            %
            %       xlscol('IV')  % returns 256
            %
            %       xlscol([405 892])  % returns {'OO' 'AHH'}
            %
            %       xlscol('A1:IV65536')  % returns [1 256]
            %
            %       xlscol({8838 2430; 253 'XFD'}) % returns {'MAX' 'COL'; 'IS' 16384}
            %
            %       xlscol(xlscol({8838 2430; 253 'XFD'})) % returns same as input
            %
            %       b = xlscol({'A10' {'IV' 'ALL34:XFC66'} {'!@#$%^&*()'} '@#$' ...
            %         {[2 3]} [5 7] 11})
            %       % returns {1 [1x3 double] 'B' 'C' 'E' 'G' 'K'}
            %       %   with b{2} = [256 1000 16383]
            %
            %   Notes
            %   -----
            %       CELLFUN and ARRAYFUN allow the program to recursively handle
            %       multiple inputs.  An interesting side effect is that mixed input,
            %       nested cells, and matrix shapes can be processed.
            %
            %   See also XLSREAD, XLSWRITE.
            %
            %   Version 1.1 - Kevin Crosby
            % DATE      VER  NAME          DESCRIPTION
            % 07-30-10  1.0  K. Crosby     First Release
            % 08-02-10  1.1  K. Crosby     Vectorized loop for numerics.
            % Contact: Kevin.L.Crosby@gmail.com
            base = 26;
            if iscell(a)
                b = cellfun(@xlscol, a, 'UniformOutput', false); % handles mixed case too
            elseif ischar(a)
                if ~isempty(strfind(a, ':')) % i.e. if is a range
                    b = cellfun(@xlscol, regexp(a, ':', 'split'));
                else % if isempty(strfind(a, ':')) % i.e. if not a range
                    b = a(isletter(a));        % get rid of numbers and symbols
                    if isempty(b)
                        b = {[]};
                    else % if ~isempty(a);
                        b = double(upper(b)) - 64; % convert ASCII to number from 1 to 26
                        n = length(b);             % number of characters
                        b = b * base.^((n-1):-1:0)';
                    end % if isempty(a)
                end % if ~isempty(strfind(a, ':')) % i.e. if is a range
            elseif isnumeric(a) && numel(a) ~= 1
                b = arrayfun(@xlscol, a, 'UniformOutput', false);
            else % if isnumeric(a) && numel(a) == 1
                n = ceil(log(a)/log(base));  % estimate number of digits
                d = cumsum(base.^(0:n+1));   % offset
                n = find(a >= d, 1, 'last'); % actual number of digits
                d = d(n:-1:1);               % reverse and shorten
                r = mod(floor((a-d)./base.^(n-1:-1:0)), base) + 1;  % modulus
                b = char(r+64);  % convert number to ASCII
            end % if iscell(a)
            % attempt to "flatten" cell, by removing nesting
            if iscell(b) && (iscell([b{:}]) || isnumeric([b{:}]))
                b = [b{:}];
            end % if iscell(b) && (iscell([b{:}]) || isnumeric([ba{:}]))
        end
        %------------------------------------------------------------------------------------------
        function surf2stl(filename,x,y,z,mode)
            %SURF2STL   Write STL file from surface data.
            %   SURF2STL('filename',X,Y,Z) writes a stereolithography (STL) file
            %   for a surface with geometry defined by three matrix arguments, X, Y
            %   and Z.  X, Y and Z must be two-dimensional arrays with the same size.
            %
            %   SURF2STL('filename',x,y,Z), uses two vector arguments replacing
            %   the first two matrix arguments, which must have length(x) = n and
            %   length(y) = m where [m,n] = size(Z).  Note that x corresponds to
            %   the columns of Z and y corresponds to the rows.
            %
            %   SURF2STL('filename',dx,dy,Z) uses scalar values of dx and dy to
            %   specify the x and y spacing between grid points.
            %
            %   SURF2STL(...,'mode') may be used to specify the output format.
            %
            %     'binary' - writes in STL binary format (default)
            %     'ascii'  - writes in STL ASCII format
            %
            %   Example:
            %
            %     surf2stl('test.stl',1,1,peaks);
            %
            %   See also SURF.
            %
            %   Author: Bill McDonald, 02-20-04
            error(nargchk(4,5,nargin));
            if (ischar(filename)==0)
                error( 'Invalid filename');
            end
            if (nargin < 5)
                mode = 'binary';
            elseif (strcmp(mode,'ascii')==0)
                mode = 'binary';
            end
            if (ndims(z) ~= 2)
                error( 'Variable z must be a 2-dimensional array' );
            end
            if any( (size(x)~=size(z)) | (size(y)~=size(z)) )
                
                % size of x or y does not match size of z
                
                if ( (length(x)==1) & (length(y)==1) )
                    % Must be specifying dx and dy, so make vectors
                    dx = x;
                    dy = y;
                    x = ((1:size(z,2))-1)*dx;
                    y = ((1:size(z,1))-1)*dy;
                end
                
                if ( (length(x)==size(z,2)) & (length(y)==size(z,1)) )
                    % Must be specifying vectors
                    xvec=x;
                    yvec=y;
                    [x,y]=meshgrid(xvec,yvec);
                else
                    error('Unable to resolve x and y variables');
                end
                
            end
            if strcmp(mode,'ascii')
                % Open for writing in ascii mode
                fid = fopen(filename,'w');
            else
                % Open for writing in binary mode
                fid = fopen(filename,'wb+');
            end
            if (fid == -1)
                error( sprintf('Unable to write to %s',filename) );
            end
            title_str = sprintf('Created by surf2stl.m %s',datestr(now));
            if strcmp(mode,'ascii')
                fprintf(fid,'solid %s\r\n',title_str);
            else
                str = sprintf('%-80s',title_str);
                fwrite(fid,str,'uchar');         % Title
                fwrite(fid,0,'int32');           % Number of facets, zero for now
            end
            nfacets = 0;
            for i=1:(size(z,1)-1)
                for j=1:(size(z,2)-1)
                    
                    p1 = [x(i,j)     y(i,j)     z(i,j)];
                    p2 = [x(i,j+1)   y(i,j+1)   z(i,j+1)];
                    p3 = [x(i+1,j+1) y(i+1,j+1) z(i+1,j+1)];
                    val = local_write_facet(fid,p1,p2,p3,mode);
                    nfacets = nfacets + val;
                    
                    p1 = [x(i+1,j+1) y(i+1,j+1) z(i+1,j+1)];
                    p2 = [x(i+1,j)   y(i+1,j)   z(i+1,j)];
                    p3 = [x(i,j)     y(i,j)     z(i,j)];
                    val = local_write_facet(fid,p1,p2,p3,mode);
                    nfacets = nfacets + val;
                    
                end
            end
            if strcmp(mode,'ascii')
                fprintf(fid,'endsolid %s\r\n',title_str);
            else
                fseek(fid,0,'bof');
                fseek(fid,80,'bof');
                fwrite(fid,nfacets,'int32');
            end
            fclose(fid);
            disp( sprintf('Wrote %d facets',nfacets) );
            % Local subfunctions
            function num = local_write_facet(fid,p1,p2,p3,mode)
                if any( isnan(p1) | isnan(p2) | isnan(p3) )
                    num = 0;
                    return;
                else
                    num = 1;
                    n = local_find_normal(p1,p2,p3);
                    
                    if strcmp(mode,'ascii')
                        
                        fprintf(fid,'facet normal %.7E %.7E %.7E\r\n', n(1),n(2),n(3) );
                        fprintf(fid,'outer loop\r\n');
                        fprintf(fid,'vertex %.7E %.7E %.7E\r\n', p1);
                        fprintf(fid,'vertex %.7E %.7E %.7E\r\n', p2);
                        fprintf(fid,'vertex %.7E %.7E %.7E\r\n', p3);
                        fprintf(fid,'endloop\r\n');
                        fprintf(fid,'endfacet\r\n');
                        
                    else
                        
                        fwrite(fid,n,'float32');
                        fwrite(fid,p1,'float32');
                        fwrite(fid,p2,'float32');
                        fwrite(fid,p3,'float32');
                        fwrite(fid,0,'int16');  % unused
                        
                    end
                    
                end
                function n = local_find_normal(p1,p2,p3)
                    v1 = p2-p1;
                    v2 = p3-p1;
                    v3 = cross(v1,v2);
                    n = v3 ./ sqrt(sum(v3.*v3));
                end
            end
        end
    end
end
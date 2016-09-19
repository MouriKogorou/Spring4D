{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2016 Spring4D Team                           }
{                                                                           }
{           http://www.spring4d.org                                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

{$I Spring.inc}

unit Spring.Data.ObjectDataSet;

interface

uses
  Classes,
  DB,
  Rtti,
  Spring,
  Spring.Collections,
  Spring.Data.ObjectDataSet.Abstract,
  Spring.Data.ObjectDataSet.Algorithms.Sort,
  Spring.Data.ObjectDataSet.ExprParser;

type
  TObjectDataSet = class(TAbstractObjectDataSet)
  private
    FDataList: IObjectList;
    FDefaultStringFieldLength: Integer;
    FFilterIndex: Integer;
    FFilterParser: TExprParser;
    FItemTypeInfo: PTypeInfo;
    FIndexFieldList: IList<TIndexFieldInfo>;
    FProperties: IList<TRttiProperty>;
    FSort: string;
    FSorted: Boolean;
    FColumnAttributeClass: TAttributeClass;
    FTrackChanges: Boolean;

    FBeforeFilter: TDataSetNotifyEvent;
    FAfterFilter: TDataSetNotifyEvent;
    FBeforeSort: TDataSetNotifyEvent;
    FAfterSort: TDataSetNotifyEvent;

    function GetSort: string;
    procedure SetSort(const Value: string);
    function GetFilterCount: Integer;
    procedure RegisterChangeHandler;
    procedure UnregisterChangeHandler;
    procedure SetDataList(const Value: IObjectList);
    procedure SetTrackChanges(const Value: Boolean);
  protected
    procedure DoAfterOpen; override;
    procedure DoDeleteRecord(Index: Integer); override;
    procedure DoGetFieldValue(Field: TField; Index: Integer; var Value: Variant); override;
    procedure DoPostRecord(Index: Integer; Append: Boolean); override;
    procedure RebuildPropertiesCache; override;

    function DataListCount: Integer;
    function GetRecordCount: Integer; override;
    function RecordConformsFilter: Boolean; override;
    procedure UpdateFilter; override;

    procedure DoAfterFilter; virtual;
    procedure DoAfterSort; virtual;
    procedure DoBeforeFilter; virtual;
    procedure DoBeforeSort; virtual;

    procedure DoOnDataListChange(Sender: TObject; const Item: TObject; Action: TCollectionChangedAction);

    function CompareRecords(const Item1, Item2: TObject;
      const AIndexFieldList: IList<TIndexFieldInfo>): Integer; virtual;
    function InternalGetFieldValue(AField: TField; const AItem: TValue): Variant; virtual;
    function ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean; virtual;
    function ParserGetFunctionValue(Sender: TObject; const FuncName: string;
      const Args: Variant; var ResVal: Variant): Boolean; virtual;
    procedure DoFilterRecord(AIndex: Integer); virtual;
    procedure InitRttiPropertiesFromItemType(AItemTypeInfo: PTypeInfo); virtual;
    procedure InternalSetSort(const AValue: string; AIndex: Integer = 0); virtual;
    procedure LoadFieldDefsFromFields(Fields: TFields; FieldDefs: TFieldDefs); virtual;
    procedure LoadFieldDefsFromItemType; virtual;
    procedure RefreshFilter; virtual;

    function  IsCursorOpen: Boolean; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    procedure InternalClose; override;
    procedure SetFilterText(const Value: string); override;

    function GetChangedSortText(const ASortText: string): string;
    function CreateIndexList(const ASortText: string): IList<TIndexFieldInfo>;
    function FieldInSortIndex(AField: TField): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    ///   Makes the current dataset clone of <c>ASource</c>.
    /// </summary>
    procedure Clone(const ASource: TObjectDataSet);

    /// <summary>
    ///   Returns underlying model object from the current row.
    /// </summary>
    function GetCurrentModel<T: class>: T;

    /// <summary>
    ///   Returns newly created list of data containing only filtered items.
    /// </summary>
    function GetFilteredDataList<T: class>: IList<T>;

    /// <summary>
    ///   Returns the total count of filtered records.
    /// </summary>
    property FilterCount: Integer read GetFilterCount;

    /// <summary>
    ///   Checks if dataset is sorted.
    /// </summary>
    property Sorted: Boolean read FSorted;

    /// <summary>
    ///   Sorting conditions separated by commas. Can set different sort order
    ///   for multiple fields - <c>Asc</c> stands for ascending, <c>Desc</c> -
    ///   descending.
    /// </summary>
    /// <example>
    ///   <code lang="">MyDataset.Sort := 'Name, Id Desc, Description Asc';</code>
    /// </example>
    property Sort: string read GetSort write SetSort;

    /// <summary>
    ///   Class of the column attribute. If properties of the entity class are
    ///   annotated with this attribute, then the dataset will use these
    ///   properties as fields. If ColumnAttributeClass is null, all the
    ///   published properties of the entity class will be used as dataset
    ///   fields.
    /// </summary>
    /// <example>
    ///   <code lang="">MyDataset.ColumnAttributeClass := ColumnAttribute</code>
    /// </example>
    property ColumnAttributeClass: TAttributeClass
      read FColumnAttributeClass write FColumnAttributeClass;

    /// <summary>
    ///   The list of objects to display in the dataset.
    /// </summary>
    property DataList: IObjectList read FDataList write SetDataList;
  published
    /// <summary>
    ///   Default length for the string type field in the dataset.
    /// </summary>
    /// <remarks>
    ///   Defaults to <c>250</c> if not set.
    /// </remarks>
    property DefaultStringFieldLength: Integer read FDefaultStringFieldLength write FDefaultStringFieldLength default 250;
    property TrackChanges: Boolean read FTrackChanges write SetTrackChanges default False;

    property Filter;
    property Filtered;
    property FilterOptions;

    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterRefresh;
    property AfterScroll;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeRefresh;
    property BeforeScroll;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;

    property BeforeFilter: TDataSetNotifyEvent read FBeforeFilter write FBeforeFilter;
    property AfterFilter: TDataSetNotifyEvent read FAfterFilter write FAfterFilter;
    property BeforeSort: TDataSetNotifyEvent read FBeforeSort write FBeforeSort;
    property AfterSort: TDataSetNotifyEvent read FAfterSort write FAfterSort;
  end;

implementation

uses
  Math,
  StrUtils,
  SysUtils,
  Types,
  TypInfo,
  Variants,
  Spring.Reflection,
  Spring.SystemUtils,
  Spring.Data.ObjectDataSet.ExprParser.Functions;

type
  EObjectDataSetException = class(Exception);
  
  {$WARNINGS OFF}
  TWideCharSet = set of Char;
  {$WARNINGS ON}


{$REGION 'TObjectDataSet'}

constructor TObjectDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProperties := TCollections.CreateList<TRttiProperty>;
  FFilterParser := TExprParser.Create;
  FFilterParser.OnGetVariable := ParserGetVariableValue;
  FFilterParser.OnExecuteFunction := ParserGetFunctionValue;
  FDefaultStringFieldLength := 250;
end;

destructor TObjectDataSet.Destroy;
begin
  FFilterParser.Free;
  inherited Destroy;
end;

procedure TObjectDataSet.Clone(const ASource: TObjectDataSet);
begin
  if Active then
    Close;

  FColumnAttributeClass := ASource.FColumnAttributeClass;
  FItemTypeInfo := ASource.FItemTypeInfo;
  FDataList := ASource.DataList;
  IndexList.DataList := ASource.IndexList.DataList;

  FilterOptions := ASource.FilterOptions;
  Filter := ASource.Filter;
  Filtered := ASource.Filtered;
  Open;
  if ASource.Sorted then
    Sort := ASource.Sort;
end;

function TObjectDataSet.CompareRecords(const Item1, Item2: TObject;
  const AIndexFieldList: IList<TIndexFieldInfo>): Integer;
var
  i: Integer;
  LFieldInfo: TIndexFieldInfo;
  LValue1, LValue2: TValue;
begin
  Result := 0;

  for i := 0 to AIndexFieldList.Count - 1 do
  begin
    LFieldInfo := AIndexFieldList[i];
    LValue1 := LFieldInfo.RttiProperty.GetValue(Item1);
    LValue2 := LFieldInfo.RttiProperty.GetValue(Item2);

    Result := LValue1.CompareTo(LValue2);
    if LFieldInfo.Descending then
      Result := -Result;

    if Result <> 0 then
      Exit;
  end;
end;

function TObjectDataSet.CreateIndexList(const ASortText: string): IList<TIndexFieldInfo>;
var
  LText, LItem: string;
  LSplittedFields: TStringDynArray;
  LIndexFieldItem: TIndexFieldInfo;
  i: Integer;
begin
  Result := TCollections.CreateList<TIndexFieldInfo>;
  LSplittedFields := SplitString(ASortText, [','], True);
  for LText in LSplittedFields do
  begin
    LItem := UpperCase(LText);
    LIndexFieldItem.Descending := Pos('DESC', LItem) > 1;
    LItem := Trim(LText);
    i := Pos(' ', LItem);
    if i > 1 then
      LItem := Copy(LItem, 1, i - 1);

    LIndexFieldItem.Field := FindField(LItem);
    if not FProperties.TryGetFirst(LIndexFieldItem.RttiProperty,
      TPropertyFilters.IsNamed(LIndexFieldItem.Field.FieldName)) then
      raise EObjectDataSetException.CreateFmt('Field %d used for sorting not found in the dataset.', [LIndexFieldItem.Field.Name]);
    LIndexFieldItem.CaseInsensitive := True;
    Result.Add(LIndexFieldItem);
  end;
end;

function TObjectDataSet.DataListCount: Integer;
begin
  Result := 0;
  if Assigned(FDataList) then
    Result := FDataList.Count;
end;

procedure TObjectDataSet.DoAfterOpen;
begin
  if Filtered then
  begin
    UpdateFilter;
    First;
  end;
  inherited DoAfterOpen;
end;

procedure TObjectDataSet.DoDeleteRecord(Index: Integer);
begin
  IndexList.DeleteModel(Index);
end;

procedure TObjectDataSet.DoGetFieldValue(Field: TField; Index: Integer; var Value: Variant);
var
  LItem: TValue;
begin
  LItem := IndexList.GetModel(Index);
  Value := InternalGetFieldValue(Field, LItem);
end;

procedure TObjectDataSet.DoAfterFilter;
begin
  if Assigned(FAfterFilter) then
    FAfterFilter(Self);
end;

procedure TObjectDataSet.DoAfterSort;
begin
  if Assigned(FAfterSort) then
    FAfterSort(Self);
end;

procedure TObjectDataSet.DoBeforeFilter;
begin
  if Assigned(FBeforeFilter) then
    FBeforeFilter(Self);
end;

procedure TObjectDataSet.DoBeforeSort;
begin
  if Assigned(FBeforeSort) then
    FBeforeSort(Self);
end;

procedure TObjectDataSet.DoOnDataListChange(Sender: TObject;
  const Item: TObject; Action: TCollectionChangedAction);
begin
  if not Active then
    Exit;

  if IndexList.DataListIsChanging then
    Exit;
  DisableControls;
  try
    Refresh;
  finally
    EnableControls;
  end;
end;

procedure TObjectDataSet.DoPostRecord(Index: Integer; Append: Boolean);
var
  LItem: TObject;
  LConvertedValue: TValue;
  LValueFromVariant: TValue;
  LFieldValue: Variant;
  i: Integer;
  LProp: TRttiProperty;
  LField: TField;
  LNeedsSort: Boolean;
begin
  if State = dsInsert then
    LItem := TActivator.CreateInstance(FItemTypeInfo)
  else
    LItem := IndexList.GetModel(Index);

  LNeedsSort := False;

  for i := 0 to ModifiedFields.Count - 1 do
  begin
    LField := ModifiedFields[i];

    if not LNeedsSort and Sorted then
      LNeedsSort := FieldInSortIndex(LField);

    // Fields not found in dictionary are calculated or lookup fields, do not post them
    if FProperties.TryGetFirst(LProp, TPropertyFilters.IsNamed(LField.FieldName)) then
    begin
      LFieldValue := LField.Value;
      if VarIsNull(LFieldValue) then
        LProp.SetValue(LItem, TValue.Empty)
      else
      begin
        LValueFromVariant := TValue.FromVariant(LFieldValue);

        if LValueFromVariant.TryConvert(LProp.PropertyType.Handle, LConvertedValue) then
          LProp.SetValue(LItem, LConvertedValue);
      end;
    end;
  end;

  if State = dsInsert then
    if Append then
      Index := IndexList.AddModel(LItem)
    else
      IndexList.InsertModel(LItem, Index);

  DoFilterRecord(Index);
  if Sorted and LNeedsSort then
    InternalSetSort(Sort, Index);

  SetCurrent(Index);
end;

function TObjectDataSet.FieldInSortIndex(AField: TField): Boolean;
var
  i: Integer;
begin
  if Sorted and Assigned(FIndexFieldList) then
    for i := 0 to FIndexFieldList.Count - 1 do
      if AField = FIndexFieldList[i].Field then
        Exit(True);
  Result := False;
end;

function TObjectDataSet.GetChangedSortText(const ASortText: string): string;
begin
  Result := ASortText;

  if EndsStr(' ', Result) then
    Result := Copy(Result, 1, Length(Result) - 1)
  else
    Result := Result + ' ';
end;

function TObjectDataSet.GetCurrentModel<T>: T;
begin
  Result := System.Default(T);
  if Active and (Index > -1) and (Index < RecordCount) then
    Result := IndexList.GetModel(Index) as T;
end;

function TObjectDataSet.GetFilterCount: Integer;
begin
  Result := 0;
  if Filtered then
    Result := IndexList.Count;
end;

function TObjectDataSet.GetFilteredDataList<T>: IList<T>;
var
  i: Integer;
begin
  Result := TCollections.CreateList<T>;
  for i := 0 to IndexList.Count - 1 do
    Result.Add(IndexList.GetModel(i));
end;

function TObjectDataSet.GetRecordCount: Integer;
begin
  Result := IndexList.Count;
end;

function TObjectDataSet.GetSort: string;
begin
  Result := FSort;
end;

procedure TObjectDataSet.InitRttiPropertiesFromItemType(AItemTypeInfo: PTypeInfo);
var
  LType: TRttiType;
  LProp: TRttiProperty;
begin
  if AItemTypeInfo = nil then
    Exit;

  FProperties.Clear;

  LType := TType.GetType(AItemTypeInfo);
  for LProp in LType.GetProperties do
  begin
    if not (LProp.Visibility in [mvPublic, mvPublished]) then
      Continue;

    if (Fields.Count > 0) and Assigned(Fields.FindField(LProp.Name)) then
    begin
      FProperties.Add(LProp);
      Continue;
    end;

    if Assigned(FColumnAttributeClass) then
    begin
      if LProp.HasCustomAttribute(FColumnAttributeClass) then
        FProperties.Add(LProp);
    end
    else
      if LProp.Visibility = mvPublished then
        FProperties.Add(LProp);
  end;
end;

procedure TObjectDataSet.InternalClose;
begin
  inherited;
  UnregisterChangeHandler;
end;

function TObjectDataSet.InternalGetFieldValue(AField: TField; const AItem: TValue): Variant;
var
  LProperty: TRttiProperty;
begin
  if not FProperties.Any then
    InitRttiPropertiesFromItemType(AItem.TypeInfo);

  if FProperties.TryGetFirst(LProperty, TPropertyFilters.IsNamed(AField.FieldName)) then
    Result := LProperty.GetValue(AItem).ToVariant
  else
    if AField.FieldKind = fkData then
      raise EObjectDataSetException.CreateFmt(SPropertyNotFound, [AField.FieldName]);
end;

procedure TObjectDataSet.InternalInitFieldDefs;
begin
  FieldDefs.Clear;
  if Fields.Count > 0 then
    LoadFieldDefsFromFields(Fields, FieldDefs)
  else
    LoadFieldDefsFromItemType;
end;

procedure TObjectDataSet.InternalOpen;
begin
  inherited InternalOpen;
  IndexList.Rebuild;

  if {$IF CompilerVersion >= 27}(FieldOptions.AutoCreateMode <> acExclusive)
    or not (lcPersistent in Fields.LifeCycles){$ELSE}DefaultFields{$IFEND} then
    CreateFields;

  Reserved := Pointer(FieldListCheckSum);
  BindFields(True);
  SetRecBufSize;
end;

procedure TObjectDataSet.InternalSetSort(const AValue: string; AIndex: Integer);
var
  Pos: Integer;
  LDataList: IObjectList;
  LOwnedDatalist: ICollectionOwnership;
  LOwnsObjectsProp: Boolean;
  LChanged: Boolean;
begin
  if IsEmpty then
    Exit;

  DoBeforeSort;

  LChanged := AValue <> FSort;
  FIndexFieldList := CreateIndexList(AValue);

  Pos := Current;
  LDataList := FDataList;
  LOwnsObjectsProp := Supports(LDataList, ICollectionOwnership, LOwnedDatalist);
  try
    if LOwnsObjectsProp then
      LOwnedDatalist.OwnsObjects := False;
    if LChanged then
      TMergeSort.Sort(IndexList, CompareRecords, FIndexFieldList)
    else
      TInsertionSort.Sort(AIndex, IndexList, CompareRecords, FIndexFieldList);

    FSorted := FIndexFieldList.Count > 0;
    FSort := AValue;

  finally
    if LOwnsObjectsProp then
      LOwnedDatalist.OwnsObjects := True;

    SetCurrent(Pos);
  end;
  DoAfterSort;
end;

function TObjectDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FDataList) and inherited IsCursorOpen;
end;

procedure TObjectDataSet.LoadFieldDefsFromFields(Fields: TFields; FieldDefs: TFieldDefs);
var
  i: integer;
  LField: TField;
  LFieldDef: TFieldDef;
begin
  for I := 0 to Fields.Count - 1 do
  begin
    LField := Fields[I];
    if FieldDefs.IndexOf(LField.FieldName) = -1 then
    begin
      LFieldDef := FieldDefs.AddFieldDef;
      LFieldDef.Name := LField.FieldName;
      LFieldDef.DataType := LField.DataType;
      LFieldDef.Size := LField.Size;
      if LField.Required then
        LFieldDef.Attributes := [DB.faRequired];
      if LField.ReadOnly then
        LFieldDef.Attributes := LFieldDef.Attributes + [DB.faReadonly];
      if (LField.DataType = ftBCD) and (LField is TBCDField) then
        LFieldDef.Precision := TBCDField(LField).Precision;
      if LField is TObjectField then
        LoadFieldDefsFromFields(TObjectField(LField).Fields, LFieldDef.ChildDefs);
    end;
  end;
end;

procedure TObjectDataSet.LoadFieldDefsFromItemType;
var
  LProp: TRttiProperty;
  LFieldType: TFieldType;
  LFieldDef: TFieldDef;
  LLength, LPrecision, LScale: Integer;
  LRequired, LDontUpdate: Boolean;

  procedure DoGetFieldType(ATypeInfo: PTypeInfo);
  var
    LTypeInfo: PTypeInfo;
  begin
    case ATypeInfo.Kind of
      tkInteger:
      begin
        LLength := -2;
        if ATypeInfo = TypeInfo(Word) then
          LFieldType := ftWord
        else if ATypeInfo = TypeInfo(SmallInt) then
          LFieldType := ftSmallint
        else
          LFieldType := ftInteger;
      end;
      tkEnumeration:
      begin
        if ATypeInfo = TypeInfo(Boolean) then
        begin
          LFieldType := ftBoolean;
          LLength := -2;
        end
        else
        begin
          LFieldType := ftWideString;
          if LLength = -2 then
            LLength := FDefaultStringFieldLength;
        end;
      end;
      tkFloat:
      begin
        if ATypeInfo = TypeInfo(TDate) then
        begin
          LFieldType := ftDate;
          LLength := -2;
        end
        else if ATypeInfo = TypeInfo(TDateTime) then
        begin
          LFieldType := ftDateTime;
          LLength := -2;
        end
        else if ATypeInfo = TypeInfo(Currency) then
        begin
          LFieldType := ftCurrency;
          LLength := -2;
        end
        else if ATypeInfo = TypeInfo(TTime) then
        begin
          LFieldType := ftTime;
          LLength := -2;
        end
        else if (LPrecision <> -2) or (LScale <> -2) then
        begin
          LFieldType := ftBCD;
          LLength := -2;
        end
        else
        begin
          LFieldType := ftFloat;
          LLength := -2;
        end;
      end;
      tkString, tkLString, tkChar:
      begin
        LFieldType := ftString;
        if LLength = -2 then
          LLength := FDefaultStringFieldLength;
      end;
      tkVariant, tkArray, tkDynArray:
      begin
        LFieldType := ftVariant;
        LLength := -2;
      end;
      tkClass:
      begin
        if TypeInfo(TStringStream) = ATypeInfo then
          LFieldType := ftMemo
        else
          LFieldType := ftBlob;
        LLength := -2;
        LDontUpdate := True;
      end;
      tkRecord:
      begin
        if IsNullable(ATypeInfo) then
        begin
          LTypeInfo := GetUnderlyingType(ATypeInfo);
          DoGetFieldType(LTypeInfo);
        end;
      end;
      tkInt64:
      begin
        LFieldType := ftLargeint;
        LLength := -2;
      end;
      tkUString, tkWString, tkWChar, tkSet:
      begin
        LFieldType := ftWideString;
        if LLength = -2 then
          LLength := FDefaultStringFieldLength;
      end;
    end;
  end;

begin
  InitRttiPropertiesFromItemType(FItemTypeInfo);

  if not FProperties.Any then
    if Assigned(FColumnAttributeClass) then
      raise EObjectDataSetException.Create(SColumnPropertiesNotSpecified);
  for LProp in FProperties do
  begin
    LLength := -2;
    LPrecision := -2;
    LScale := -2;
    LRequired := False;
    LDontUpdate := False;
    LFieldType := ftWideString;

    DoGetFieldType(LProp.PropertyType.Handle);

    LFieldDef := FieldDefs.AddFieldDef;
    LFieldDef.Name := LProp.Name;

    LFieldDef.DataType := LFieldType;
    if LLength <> -2 then
      LFieldDef.Size := LLength;

    LFieldDef.Required := LRequired;

    if LFieldType in [ftFMTBcd, ftBCD] then
    begin
      if LPrecision <> -2 then
        LFieldDef.Precision := LPrecision;

      if LScale <> -2 then
        LFieldDef.Size := LScale;
    end;

    if LDontUpdate then
      LFieldDef.Attributes := LFieldDef.Attributes + [DB.faReadOnly];

    if not LProp.IsWritable then
      LFieldDef.Attributes := LFieldDef.Attributes + [DB.faReadOnly];
  end;
end;

function TObjectDataSet.ParserGetFunctionValue(Sender: TObject; const FuncName: string;
  const Args: Variant; var ResVal: Variant): Boolean;
var
  LGetValueFunc: TFunctionGetValueProc;
begin
  Result := TFilterFunctions.TryGetFunction(FuncName, LGetValueFunc);
  if Result then
    ResVal := LGetValueFunc(Args);
end;

function TObjectDataSet.ParserGetVariableValue(Sender: TObject;
  const VarName: string; var Value: Variant): Boolean;
var
  LField: TField;
begin
  Result := FilterCache.TryGetValue(VarName, Value);
  if not Result then
  begin
    LField := FindField(Varname);
    if Assigned(LField) then
    begin
      Value := InternalGetFieldValue(LField, FDataList[FFilterIndex]);
      FilterCache.Add(VarName, Value);
      Result := True;
    end;
  end;
end;

procedure TObjectDataSet.RebuildPropertiesCache;
var
  LType: TRttiType;
  i: Integer;
begin
  FProperties.Clear;
  LType := TType.GetType(FItemTypeInfo);
  for i := 0 to Fields.Count - 1 do
    FProperties.Add(LType.GetProperty(Fields[i].FieldName));
end;

function TObjectDataSet.RecordConformsFilter: Boolean;
begin
  Result := True;
  if (FFilterIndex >= 0) and (FFilterIndex < DataListCount) then
  begin
    if Assigned(OnFilterRecord) then
      OnFilterRecord(Self, Result)
    else
      if FFilterParser.Eval then
        Result := FFilterParser.Value;
  end
  else
    Result := False;
end;

procedure TObjectDataSet.RefreshFilter;
var
  i: Integer;
begin
  IndexList.Clear;
  if not IsFilterEntered then
  begin
    IndexList.Rebuild;
    Exit;
  end;

  for i := 0 to FDataList.Count - 1 do
  begin
    FFilterIndex := i;
    FilterCache.Clear;
    if RecordConformsFilter then
      IndexList.Add(i, FDataList[i]);
  end;
  FilterCache.Clear;
end;

procedure TObjectDataSet.RegisterChangeHandler;
begin
  UnregisterChangeHandler;
  if Assigned(FDataList) and FTrackChanges then
    FDataList.OnChanged.Add(DoOnDataListChange);
end;

procedure TObjectDataSet.DoFilterRecord(AIndex: Integer);
begin
  if IsFilterEntered and (AIndex > -1) and (AIndex < RecordCount) then
  begin
    FilterCache.Clear;
    FFilterIndex := IndexList[AIndex].DataListIndex;
    if not RecordConformsFilter then
      IndexList.Delete(AIndex);
  end;
end;

procedure TObjectDataSet.SetDataList(const Value: IObjectList);
begin
  FDataList := Value;
  FItemTypeInfo := FDataList.ElementType;
  IndexList.DataList := FDataList;
  RegisterChangeHandler;
  if Active then
    Refresh;
end;

procedure TObjectDataSet.SetFilterText(const Value: string);
begin
  if Value = Filter then
    Exit;

  if Active then
  begin
    CheckBrowseMode;
    inherited SetFilterText(Value);

    if Filtered then
    begin
      UpdateFilter;
      First;
    end
    else
    begin
      UpdateFilter;
      Resync([]);
      First;
    end;
  end
  else
    inherited SetFilterText(Value);
end;

procedure TObjectDataSet.SetSort(const Value: string);
begin
  CheckActive;
  if State in dsEditModes then
    Post;

  UpdateCursorPos;
  InternalSetSort(Value);
  Resync([]);
end;

procedure TObjectDataSet.SetTrackChanges(const Value: Boolean);
begin
  if FTrackChanges <> Value then
  begin
    FTrackChanges := Value;
    RegisterChangeHandler;
  end;
end;

procedure TObjectDataSet.UnregisterChangeHandler;
begin
  if Assigned(FDataList) then
    FDataList.OnChanged.Remove(DoOnDataListChange);
end;

procedure TObjectDataSet.UpdateFilter;
var
  LSaveState: TDataSetState;
begin
  if not Active then
    Exit;

  DoBeforeFilter;

  if IsFilterEntered then
  begin
    FFilterParser.EnableWildcardMatching := not (foNoPartialCompare in FilterOptions);
    FFilterParser.CaseInsensitive := foCaseInsensitive in FilterOptions;

    if foCaseInsensitive in FilterOptions then
      FFilterParser.Expression := AnsiUpperCase(Filter)
    else
      FFilterParser.Expression := Filter;
  end;

  LSaveState := SetTempState(dsFilter);
  try
    RefreshFilter;
  finally
    RestoreState(LSaveState);
  end;

  DisableControls;
  try
    First;
    if Sorted then
      InternalSetSort(GetChangedSortText(Sort));
  finally
    EnableControls;
  end;
  UpdateCursorPos;
  Resync([]);
  First;

  DoAfterFilter;
end;

{$ENDREGION}


end.

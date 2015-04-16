{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2014 Spring4D Team                           }
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

unit Spring.Persistence.SQL.Generators.Abstract;

interface

uses
  Rtti,
  Spring.Collections,
  Spring.Persistence.Mapping.Attributes,
  Spring.Persistence.SQL.Commands,
  Spring.Persistence.SQL.Interfaces,
  Spring.Persistence.SQL.Types,
  Spring.Persistence.SQL.Params;

const
  TBL_TEMP = 'ORM_TEMP';

type
  TAbstractSQLGenerator = class(TInterfacedObject, ISQLGenerator)
  protected
    function GetQueryLanguage: TQueryLanguage; virtual; abstract;
    function GenerateSelect(const command: TSelectCommand): string; virtual; abstract;
    function GenerateInsert(const command: TInsertCommand): string; virtual; abstract;
    function GenerateUpdate(const command: TUpdateCommand): string; virtual; abstract;
    function GenerateDelete(const command: TDeleteCommand): string; virtual; abstract;
    function GenerateCreateTable(const command: TCreateTableCommand): IList<string>; virtual; abstract;
    function GenerateCreateForeignKey(const command: TCreateForeignKeyCommand): IList<string>; virtual; abstract;
    function GenerateCreateSequence(const command: TCreateSequenceCommand): string; virtual; abstract;
    function GenerateGetNextSequenceValue(const sequence: SequenceAttribute): string; virtual; abstract;
    function GenerateGetLastInsertId(const identityColumn: ColumnAttribute): string; virtual; abstract;
    function GeneratePagedQuery(const sql: string; limit, offset: Integer): string; virtual; abstract;
    function GenerateGetQueryCount(const sql: string): string; virtual; abstract;
    function GetSQLDataTypeName(const field: TSQLCreateField): string; virtual; abstract;
    function GetSQLTableCount(const tableName: string): string; virtual; abstract;
    function GetSQLSequenceCount(const sequenceName: string): string; virtual; abstract;
    function GetTableColumns(const tableName: string): string; virtual; abstract;
    function GetSQLTableExists(const tablename: string): string; virtual; abstract;
    function GetEscapeFieldnameChar: Char; virtual; abstract;
    function GenerateUniqueId: Variant; virtual;
    function GetUpdateVersionFieldQuery(const command: TUpdateCommand;
      const versionColumn: VersionAttribute; const version, primaryKey: Variant): Variant; virtual; abstract;
    function FindEnd(const whereFields: IList<TSQLWhereField>;
      startIndex: Integer; startToken, endToken: TWhereOperator): Integer; virtual;

    function GetParamClass: TDBParamClass; virtual;
  public
    function CreateParam(const paramField: TSQLParamField; const value: TValue): TDBParam; virtual;
  end;

implementation

uses
  Spring.Persistence.Core.Utils,
  Spring.Persistence.Core.Reflection,
  Spring,
  Classes,
  Variants;


{$REGION 'TAbstractSQLGenerator'}

function TAbstractSQLGenerator.CreateParam(const paramField: TSQLParamField;
  const value: TValue): TDBParam;
var
  convertedValue: TValue;
  freeAfter: Boolean;
begin
  Result := GetParamClass.Create;
  Result.Name := paramField.ParamName;
  freeAfter := False;
  convertedValue := value;
  if not value.IsEmpty and value.IsObject then
    TryConvert(value, TypeInfo(TStream), convertedValue, freeAfter);

  Result.Value := TUtils.AsVariant(convertedValue);
  if VarIsNull(Result.Value) or VarIsEmpty(Result.Value) then
    Result.SetParamTypeFromTypeInfo(paramField.Column.MemberType);

  if freeAfter then
    convertedValue.Free;
end;

function TAbstractSQLGenerator.FindEnd(
  const whereFields: IList<TSQLWhereField>; startIndex: Integer; startToken,
  endToken: TWhereOperator): Integer;
var
  LCount: Integer;
begin
  LCount := 0;
  for Result := startIndex to whereFields.Count - 1 do
  begin
    if whereFields[Result].WhereOperator = startToken then
    begin
      Inc(LCount);
      Continue;
    end;

    if whereFields[Result].WhereOperator = endToken then
    begin
      Dec(LCount);
      if LCount = 0 then
        Exit;
    end;
  end;
  Result := startIndex;
end;

function TAbstractSQLGenerator.GenerateUniqueId: Variant;
begin
  Result := Null;
end;

function TAbstractSQLGenerator.GetParamClass: TDBParamClass;
begin
  Result := TDBParam;
end;

{$ENDREGION}


end.

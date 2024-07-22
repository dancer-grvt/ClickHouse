#!/usr/bin/env bash
# Tags: no-fasttest, long

CUR_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# reset --log_comment
CLICKHOUSE_LOG_COMMENT=
# shellcheck source=../shell_config.sh
. "$CUR_DIR"/../shell_config.sh

CH_CLIENT="$CLICKHOUSE_CLIENT --allow_experimental_json_type=1 --allow_experimental_variant_type=1 --use_variant_as_common_type=1 --session_timezone=UTC"

function insert()
{
    echo "insert"
    $CH_CLIENT -q "truncate table test"
    $CH_CLIENT -q "insert into test select number, '{}' from numbers(5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('a.b.c', number)) from numbers(5, 5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('a.b.d', number::UInt32, 'a.b.e', 'str_' || toString(number))) from numbers(10, 5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('b.b.d', number::UInt32, 'b.b.e', 'str_' || toString(number))) from numbers(15, 5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('a.b.c', number, 'a.b.d', number::UInt32, 'a.b.e', 'str_' || toString(number))) from numbers(20, 5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('a.b.c', number, 'a.b.d', number::UInt32, 'a.b.e', 'str_' || toString(number), 'b.b._' || toString(number), number::UInt32)) from numbers(25, 5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('a.b.c', number, 'a.b.d', range(number % + 1)::Array(UInt32), 'a.b.e', 'str_' || toString(number), 'd.a', number::UInt32, 'd.c', toDate(number))) from numbers(30, 5)"
    $CH_CLIENT -q "insert into test select number, toJSONString(map('a.b.c', number, 'a.b.d', toDateTime(number), 'a.b.e', 'str_' || toString(number), 'd.a', range(number % 5 + 1)::Array(UInt32), 'd.b', number::UInt32)) from numbers(35, 5)"
}

function test()
{
    echo "test"
    $CH_CLIENT -q "select distinct arrayJoin(JSONAllPathsWithTypes(json)) as paths_with_types from test order by paths_with_types"

    $CH_CLIENT -q "select json.non.existing.path, json.a.b.c, json.a.b.d, json.a.b.d.:Int64, json.a.b.d.:UUID, json.a.b.e, json.a.b.e.:String, json.a.b.e.:UUID, json.b.b.\`_25\`, json.b.b.\`_25\`.:Int64, json.b.b.\`_25\`.:UUID, json.b.b.\`_26\`, json.b.b.\`_26\`.:Int64, json.b.b.\`_26\`.:UUID, json.b.b.\`_27\`, json.b.b.\`_27\`.:Int64, json.b.b.\`_27\`.:UUID, json.b.b.\`_28\`, json.b.b.\`_28\`.:Int64, json.b.b.\`_28\`.:UUID, json.b.b.\`_29\`, json.b.b.\`_29\`.:Int64,  json.b.b.\`_29\`.:UUID, json.b.b.d, json.b.b.d.:Int64, json.b.b.d.:UUID, json.b.b.e, json.b.b.e.:String, json.b.b.e.:UUID, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:UUID, json.d.b, json.d.b.:Int64, json.d.b.:UUID, json.d.c, json.d.c.:Date, json.d.c.:UUID, json.^n, json.^a, json.^a.b, json.^b, json.^d from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.non.existing.path, json.a.b.c, json.a.b.d, json.a.b.d.:Int64, json.a.b.d.:UUID, json.a.b.e, json.a.b.e.:String, json.a.b.e.:UUID, json.b.b.\`_25\`, json.b.b.\`_25\`.:Int64, json.b.b.\`_25\`.:UUID, json.b.b.\`_26\`, json.b.b.\`_26\`.:Int64, json.b.b.\`_26\`.:UUID, json.b.b.\`_27\`, json.b.b.\`_27\`.:Int64, json.b.b.\`_27\`.:UUID, json.b.b.\`_28\`, json.b.b.\`_28\`.:Int64, json.b.b.\`_28\`.:UUID, json.b.b.\`_29\`, json.b.b.\`_29\`.:Int64,  json.b.b.\`_29\`.:UUID, json.b.b.d, json.b.b.d.:Int64, json.b.b.d.:UUID, json.b.b.e, json.b.b.e.:String, json.b.b.e.:UUID, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:UUID, json.d.b, json.d.b.:Int64, json.d.b.:UUID, json.d.c, json.d.c.:Date, json.d.c.:UUID, json.^n, json.^a, json.^a.b, json.^b, json.^d from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.non.existing.path from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.non.existing.path.:Int64 from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.non.existing.path, json.non.existing.path.:Int64 from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.non.existing.path from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.non.existing.path.:Int64 from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.non.existing.path, json.non.existing.path.:Int64 from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.a.b.c from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.a.b.c from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.b.b.e from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e.:String, json.b.b.e.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e.:String, json.b.b.e.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.b.b.e, json.a.b.d from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e.:String, json.b.b.e.:Date, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date, json.a.b.d, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.a.b.d from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e.:String, json.b.b.e.:Date, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date, json.a.b.d, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.b.b.e, json.d.a from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e.:String, json.b.b.e.:Date, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.d.a from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e.:String, json.b.b.e.:Date, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.b.b.e, json.d.a, json.d.b from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e.:String, json.b.b.e.:Date, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.d.a, json.d.b from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e.:String, json.b.b.e.:Date, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.b.b.e, json.b.b.e.:String, json.b.b.e.:Date, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.d.a, json.d.b from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.d.a, json.d.b from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.d.b, json.d.b.:Int64, json.d.b.:Date from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.d.a, json.b.b.\`_26\` from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.b.b.\`_26\`.:Int64, json.b.b.\`_26\`.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.b.b.\`_26\`.:Int64, json.b.b, json.b.b.\`_26\`.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.d.a, json.b.b.\`_26\` from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.b.b.\`_26\`.:Int64, json.b.b.\`_26\`.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.d.a, json.d.a.:\`Array(Nullable(Int64))\`, json.d.a.:Date, json.b.b.\`_26\`.:Int64, json.b.b, json.b.b.\`_26\`.:Date from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.^a, json.a.b.c from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.^a, json.a.b.c from test order by id format JSONColumns"

    $CH_CLIENT -q "select json.^a, json.a.b.d from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.^a, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json.^a, json.a.b.d, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.^a, json.a.b.d from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.^a, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
    $CH_CLIENT -q "select json, json.^a, json.a.b.d, json.a.b.d.:Int64, json.a.b.d.:Date from test order by id format JSONColumns"
}

$CH_CLIENT -q "drop table if exists test;"

$CH_CLIENT -q "create table test (id UInt64, json JSON(max_dynamic_paths=2, a.b.c UInt32)) engine=MergeTree order by id settings min_rows_for_wide_part=1, min_bytes_for_wide_part=1;"
echo "No merges"
$CH_CLIENT -q "system stop merges test"
insert
test
echo "With merges"
$CH_CLIENT -q "system start merges test"
test
$CH_CLIENT -q "drop table test;"

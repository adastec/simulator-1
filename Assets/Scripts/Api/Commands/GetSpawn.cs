/**
 * Copyright (c) 2019 LG Electronics, Inc.
 *
 * This software contains code licensed as described in LICENSE.
 *
 */

using SimpleJSON;
using UnityEngine;
using System.Linq;
using Simulator.Utilities;

namespace Simulator.Api.Commands
{
    class GetSpawn : ICommand
    {
        public string Name => "map/spawn/get";

        public void Execute(JSONNode args)
        {
            var spawns = new JSONArray();
            var api = ApiManager.Instance;

            foreach (var spawn in Object.FindObjectsOfType<SpawnInfo>().OrderBy(spawn => spawn.name))
            {
                var position = spawn.transform.position;
                var rotation = spawn.transform.rotation.eulerAngles;
                var name = spawn.transform.name; //ADASTEC
                var s = new JSONObject();
                s.Add("position", position);
                s.Add("rotation", rotation);
                s.Add("name", name);
                spawns.Add(s);
            }
            api.SendResult(this, spawns);
        }
    }
}

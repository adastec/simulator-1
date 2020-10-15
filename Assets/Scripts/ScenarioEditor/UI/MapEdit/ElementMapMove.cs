/**
 * Copyright (c) 2020 LG Electronics, Inc.
 *
 * This software contains code licensed as described in LICENSE.
 *
 */

namespace Simulator.ScenarioEditor.UI.MapEdit
{
    using System;
    using Elements;

    /// <summary>
    /// Feature allowing to move a map element
    /// </summary>
    public class ElementMapMove : IElementMapEdit
    {
        /// <inheritdoc/>
        public string Title { get; } = "Move";
        
        /// <inheritdoc/>
        public ScenarioElement CurrentElement { get; set; }

        /// <inheritdoc/>
        public bool CanEditElement(ScenarioElement element)
        {
            return element.CanBeMoved;
        }
        
        /// <inheritdoc/>
        public void Edit()
        {
            if (CurrentElement == null)
                throw new ArgumentException("Current agent has to be set by external script before editing.");
            CurrentElement.StartDragMovement();
        }
    }
}
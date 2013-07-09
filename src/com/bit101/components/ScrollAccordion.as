

package com.bit101.components {
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ScrollAccordion extends ScrollPane
	{
		protected var _windows:Array;
		protected var _vbox:VBox;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Panel.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 */
		public function ScrollAccordion(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		/**
		 * Initializes the component.
		 */
		protected override function init():void
		{
			super.init();
			setSize(100, 120);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren() : void
		{
			super.addChildren();
			_vbox = new VBox(this);
			_vbox.spacing = 0;
			_vbox.addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);

			_windows = new Array();
			
			_hScrollbar.alpha = 0;
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Adds a new window to the bottom of the accordion.
		 * @param title The title of the new window.
		 */
		public function addWindow(title:String):Window
		{
			return addWindowAt(title, _windows.length);
		}
		
		public function addWindowAt(title:String, index:int):Window
		{
			index = Math.min(index, _windows.length);
			index = Math.max(index, 0);
			var window:Window = new Window(null, 0, 0, title);
			_vbox.addChildAt(window, index);
			window.minimized = (_windows.length!=0);
			window.draggable = false;
			window.grips.visible = false;
			window.addEventListener(Event.SELECT, onWindowSelect);
			_windows.splice(index, 0, window);
			
			draw();
			
			return window;
		}

		public function removeAllWindows() : void {
			for each(var window:Window in _windows){
				window.removeEventListener(Event.SELECT, onWindowSelect);
				_vbox.removeChild(window);
			}
			_windows = [];
		}
		
		/**
		 * Sets the size of the component.
		 * @param w The width of the component.
		 * @param h The height of the component.
		 */
		override public function setSize(w:Number, h:Number) : void
		{
			super.setSize(w, h);
			_width = w;
			_height = h;
			draw();
		}
		
		override public function draw():void
		{
			super.draw();
			
			//_winHeight = Math.max(_winHeight, 40);
			var stack:Number = 0;
			for(var i:int = 0; i < _windows.length; i++)
			{
				var window:Window = _windows[i];
				var bounds:Rectangle = window.content.getBounds(window);
				window.setSize(_width-_vScrollbar.width, bounds.y+bounds.height);
				stack += window.content.height;
			}
			_vbox.setSize(_width-_vScrollbar.width, stack);
			
			_vScrollbar.height = _height;
			_corner.visible = false;
		}
		
		/**
		 * Returns the Window at the specified index.
		 * @param index The index of the Window you want to get access to.
		 */
		public function getWindowAt(index:int):Window
		{
			return _windows[index];
		}

		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Called when any window is resized. If the window has been expanded, it closes all other windows.
		 */
		protected function onWindowSelect(event:Event):void
		{
			var window:Window = event.target as Window;
			if(window.minimized)
			{
				for(var i:int = 0; i < _windows.length; i++)
				{
					var otherWindows:Window = _windows[i];
					otherWindows.minimized = (otherWindows!=window);
					if(otherWindows==window && _vScrollbar.value>i*20){
						_vScrollbar.value = i*20;
					}
				}
				
			}
			_vbox.draw();
			invalidate();
		}
		
		public override function set width(w:Number):void
		{
			_width = w;
			super.width = w;
		}
		
		/*public override function set height(h:Number):void
		{
			_winHeight = h - (_windows.length - 1) * 20;
			super.height = h;
		}*/
		
	}
}
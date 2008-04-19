/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2007
 *
 *  Last modified:
 *     $Date: 2008-01-13 13:20:50 +0100 (Sun, 13 Jan 2008) $ by $Author: schulte $
 *     $Revision: 5857 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#ifndef GECODE_GIST_PREFERENCES_HH
#define GECODE_GIST_PREFERENCES_HH

#include <QtGui>

namespace Gecode { namespace Gist {
  
  /**
   * \brief Preferences dialog for %Gist
   */
  class PreferencesDialog : public QDialog {
    Q_OBJECT
    
  protected:
    QCheckBox* hideCheck;
    QCheckBox* zoomCheck;
    QSpinBox*  refreshBox;
  protected Q_SLOTS:
    /// Write settings
    void writeBack(void);
    /// Reset to defaults
    void defaults(void);
  public:
    /// Constructor
    PreferencesDialog(QWidget* parent = 0);
    
    /// Whether to automatically hide failed subtrees during search
    bool hideFailed;
    /// Whether to automatically zoom during search
    bool zoom;
    /// How often to refresh the display during search
    int refresh;
    
  };
  
}}

#endif

// STATISTICS: gist-any